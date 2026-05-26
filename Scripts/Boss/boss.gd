@tool#加了以後process相關的程式碼會開始執行，要確保Core那邊的process有return，不然會瘋狂報錯
extends Core
class_name Boss

#近戰
@export var slash_scene: PackedScene  # 記得把 Slash.tscn 拖進來！
@export var slash_offset: float = 60.0 # 劍氣生成的偏移距離 (可以隨圖片大小微調)
@export var slash_scale: Vector2 = Vector2(1, 1)

#所有的狀態
@onready var idle_state: State = $States/Idle
@onready var approach_state: State = $States/Approach
@onready var flank_state: State = $States/Flank
@onready var dash_state: State = $States/Dash
@onready var shoot_state: State = $States/Shoot 
@onready var melee_state: State = $States/Melee
@onready var retreat_state: State = $States/Retreat
#決策
@onready var close_state: State = $States/Close
@onready var mid_state: State = $States/Mid
@onready var far_state: State = $States/Far

@export var close_mid_range: float = 100
@export var mid_far_range: float = 200

@export var show_debug_range: bool = true
#遠程
@onready var shooter: Shooter = $Shooter 

#情報
var player: Node2D
var distance_to_player: float = 0.0

# ⏳ 擴充型冷卻系統 (Dictionary)
@export var max_cooldowns: Dictionary = {
	"dash": 5.0,
	"melee": 20.0,
	"shoot": 6.0
}
# ⏳ 內部計時器 (純粹用來倒數)
var current_cooldowns: Dictionary = {}

func init_behavior():
	player = get_tree().get_first_node_in_group("Player")
	
	# 💡 防呆報錯：檢查節點是否有掛好
	if idle_state == null:
		push_error("🚨 嚴重錯誤：Boss 找不到 Idle 狀態節點！")
		return
	# 💡 動態初始化：根據你在面板設定的招式，自動生成對應的內部計時器並歸零
	for skill in max_cooldowns.keys():
		current_cooldowns[skill] = 0.0
	
	set_state(idle_state)

# ===== ✅ Editor + Runtime 都更新 =====
func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()  # Scene 視窗即時更新
	else:
		if show_debug_range:
			queue_redraw()
		super._process(delta)

func _physics_process(delta):
	if is_dead: return
	if Engine.is_editor_hint():
		return
	# 持續更新距離情報
	if player:
		distance_to_player = global_position.distance_to(player.global_position)

	# 自動扣減所有技能的冷卻時間
	for skill in current_cooldowns.keys():
		if current_cooldowns[skill] > 0.0:
			current_cooldowns[skill] = max(0.0, current_cooldowns[skill] - delta)

	super._physics_process(delta) 

# --- 🧠 大腦決策區：集中管理所有狀態切換 ---
func select_state():
	# 防禦性程式設計
	
	#改成自動抓States底下的子節點
	if idle_state == null or dash_state == null or shoot_state == null or melee_state == null:
		print("有State未導入")
		return
	#print("bstate: ",state.name," complete: ",state.is_complete)
		
	if distance_to_player < close_mid_range:
		set_state(close_state)
	elif distance_to_player < mid_far_range:
		set_state(mid_state)
	else:
		set_state(far_state)
	#print("astate: ",state.name," complete: ",state.is_complete)

# --- ⚔️ 提供給 MeleeState 呼叫的近戰攻擊指令 ---
func execute_melee_attack():
	if slash_scene == null:
		push_error("🚨 忘記把 MeleeAura.tscn 拖進 Boss 的 Melee Scene 欄位了！")
		return
	if player == null: return

	var slash = slash_scene.instantiate()
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
	
	get_parent().add_child(slash) # 加在 Boss 的父節點(競技場)上，揮出後不會跟著 Boss 滑動
	
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
			body.take_damage(2) # 衝撞傷害，一次扣 2 滴血
			print("💥 Boss 撞擊！玩家受到 2 點傷害！")
			
func start_cd(skill_name: String):
	if current_cooldowns.has(skill_name):
		current_cooldowns[skill_name] = max_cooldowns[skill_name]
	else:
		push_error("🚨 錯誤：嘗試啟動未註冊的技能冷卻 -> " + skill_name)

func is_skill_ready(skill_name: String) -> bool:
	return current_cooldowns.has(skill_name) and current_cooldowns[skill_name] <= 0.0

func is_phase2() -> bool:
	return current_hp < max_hp * 0.5

func die():
	super.die()
	print("💀 Boss死亡！")
	queue_free()


# ===== ✅ Debug 繪圖 =====
func _draw():
	if not Engine.is_editor_hint() and show_state_debug:
		if machine == null or machine.state == null:
			return

		# ✅ 拿到所有巢狀 State
		var states: Array = machine.get_actives_state_branch()

		if states.is_empty():
			return

		# ✅ 轉字串
		var names: Array[String] = []
		for s in states:
			names.append(s.name)

		var text := "States: " + " > ".join(names)

		# ✅ 顯示位置（角色頭上）
		var pos := Vector2(0, -150)

		draw_string(
			debug_font,
			pos,
			text,
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			16,
			Color.WHITE
		)
	if not show_debug_range or not Engine.is_editor_hint():
		return

	# --- 區間圓 ---
	draw_circle(Vector2.ZERO, close_mid_range, Color(0, 1, 0, 0.15))
	draw_circle(Vector2.ZERO, mid_far_range, Color(1, 1, 0, 0.15))

	draw_arc(Vector2.ZERO, close_mid_range, 0, TAU, 64, Color.GREEN, 2.0)
	draw_arc(Vector2.ZERO, mid_far_range, 0, TAU, 64, Color.YELLOW, 2.0)

	# --- 玩家方向線（避免 editor 爆錯）---
	if is_instance_valid(player):
		var local_pos = to_local(player.global_position)
		draw_line(Vector2.ZERO, local_pos, Color.CYAN, 2.0)
