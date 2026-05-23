# res://Scripts/Boss/boss.gd
extends Core
class_name Boss

@export var slash_scene: PackedScene  # 記得把 Slash.tscn 拖進來！
@export var slash_offset: float = 60.0 # 劍氣生成的偏移距離 (可以隨圖片大小微調)
@export var slash_scale: Vector2 = Vector2(1, 1)

@onready var idle_state: State = $States/Idle
@onready var dash_state: State = $States/Dash
@onready var shoot_state: State = $States/Shoot 
@onready var melee_state: State = $States/Melee

@onready var shooter: Shooter = $Shooter 

var player: Node2D
var dash_direction: Vector2 = Vector2.ZERO

func init_behavior():
	player = get_tree().get_first_node_in_group("Player")
	
	# 💡 防呆報錯：檢查節點是否有掛好
	if idle_state == null:
		push_error("🚨 嚴重錯誤：Boss 找不到 Idle 狀態節點！")
		return
		
	set_state(idle_state)

func _physics_process(delta):
	if is_dead: return

	super._physics_process(delta) 

# --- 🧠 大腦決策區：集中管理所有狀態切換 ---
func select_state():
	# 防禦性程式設計
	if idle_state == null or dash_state == null or shoot_state == null or melee_state == null:
		print("有State未導入")
		return
		
	if state == idle_state:
		set_state(melee_state) # 發呆完先砍一刀
		print("👹 Boss 決策 -> 近戰揮砍 (Melee)")
		
	elif state == melee_state:
		set_state(dash_state)  # 砍完接著衝撞
		print("👹 Boss 決策 -> 鎖定玩家衝撞 (Dash)")
		
	elif state == dash_state:
		set_state(shoot_state) # 衝完發射彈幕
		print("👹 Boss 決策 -> 開始全方位射擊 (Shoot)")
		
	elif state == shoot_state:
		set_state(idle_state)  # 射完回歸發呆
		print("👹 Boss 決策 -> 休息發呆 (Idle)")

# --- ⚔️ 提供給 MeleeState 呼叫的近戰攻擊指令 ---
func execute_melee_attack():
	if slash_scene == null:
		push_error("🚨 忘記把 MeleeAura.tscn 拖進 Boss 的 Melee Scene 欄位了！")
		return
	if player == null: return

	var slash = slash_scene.instantiate()
	get_parent().add_child(slash) # 加在 Boss 的父節點(競技場)上，揮出後不會跟著 Boss 滑動

	# 1. 計算 Boss 到玩家的方向向量
	var dir = global_position.direction_to(player.global_position)

	# 2. 設定位置 = Boss 中心點 + (方向向量 * 偏移距離)
	slash.global_position = global_position + (dir * slash_offset)

	# 3. 設定旋轉角度
	# Godot 的 dir.angle() 預設 0 度是朝右。
	# 因為你的劍氣圖片「預設朝下」，所以要扣掉 90 度 (相當於 PI / 2 弧度) 來校正！
	slash.rotation = dir.angle() - (PI / 2.0)
	# 4. 設定劍氣的大小！
	# 只要在 Boss 的 Inspector 把 melee_scale 改成 (2, 2)，
	# 劍氣的圖片和碰撞箱會同步等比例放大，不用再重新設定場景！
	slash.scale = slash_scale
	
# --- 🔫 提供給 ShootState 呼叫的武器開火指令 ---
func execute_ring_attack():
	if shooter:
		shooter.fire_ring(12, 400.0)
	else:
		push_warning("⚠️ Boss 嘗試開火，但找不到 Shooter 節點！")


# 當有實體(body)撞進 Boss 的傷害光環時觸發
func _on_damage_aura_body_entered(body: Node2D) -> void:
	# 檢查撞進來的是不是玩家
	if body.is_in_group("Player"):
		# 檢查玩家身上有沒有受傷的函式
		if body.has_method("take_damage"):
			body.take_damage(2) # 衝撞傷害，一次扣 20 滴血！
			print("💥 Boss 撞擊！玩家受到 2 點傷害！")
func die():
	super.die()
	print("💀 Boss死亡！")
	queue_free()
