extends Area2D

# --- 自定義屬性面板 ---
@export var damage: int = 1
@export var target_group: String = "Enemy" # 決定要打誰：填 "Enemy" 打敵人，填 "Player" 打玩家
@export var start_frame: int = 1           # 傷害開始判定的動畫幀
@export var end_frame: int = 2             # 傷害結束判定的動畫幀

@onready var anim = $AnimatedSprite2D

# 核心防呆機制：「黑名單」陣列。
# 記錄已經砍過誰，避免在同一刀的連續判定時間內，對同一個目標重複扣血。
var hit_targets: Array = []

func _ready():
	# 1. 劍氣一生成，就立刻播放揮砍動畫
	anim.play("slash")
	
	# 2. 綁定動畫結束的內建訊號。當動畫播完時，自動去呼叫 _on_animation_finished
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta):
	# 3. 每秒 60 次檢查：現在播到的動畫幀，是不是剛好落在我們設定的「傷害有效區間」？
	if anim.frame >= start_frame and anim.frame <= end_frame:
		deal_damage()

func deal_damage():
	# 4. 瞬間掃描：取得目前剛好站在這個 Area2D 碰撞框內的所有物理實體
	var targets = get_overlapping_bodies()
	
	for target in targets:
		# 條件 A：對方是不是我們要打的群組？
		# 條件 B：他是不是還沒被這刀砍過？ (確保不在黑名單內)
		if target.is_in_group(target_group) and target not in hit_targets:
			# 條件 C：對方身上有沒有 take_damage 這個受傷功能？
			if target.has_method("take_damage"):
				target.take_damage(damage) # 給予傷害
				
				# 扣血後立刻加入黑名單！這道劍氣消失前，絕對不會對他扣第二次血
				hit_targets.append(target) 

func _on_animation_finished():
	# 5. 動畫播完，劍氣完成任務。
	# 呼叫 queue_free() 將「自己」排入引擎的安全銷毀佇列中，在幀末自動清除。
	queue_free()
