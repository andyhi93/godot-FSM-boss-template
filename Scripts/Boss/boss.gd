# res://Scripts/Boss/boss.gd
extends Core
class_name Boss

@onready var idle_state: State = $States/Idle
@onready var dash_state: State = $States/Dash
@onready var shoot_state: State = $States/Shoot 

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
	
	# --- 🏃 肉體執行區：根據當前狀態，決定物理速度 ---
	if state == idle_state or state == shoot_state:
		velocity = Vector2.ZERO # 發呆跟射擊時，停在原地
		
	elif state == dash_state:
		# 讀取 DashState 的計時器來決定行為
		if state.time < 1.0:
			velocity = Vector2.ZERO # 蓄力前搖 1 秒
		else:
			velocity = dash_direction * 800.0 # 衝刺！

	super._physics_process(delta) 

# --- 🧠 大腦決策區：集中管理所有狀態切換 ---
func select_state():
	# 防禦性程式設計
	if idle_state == null or dash_state == null or shoot_state == null:
		return
		
	if state == idle_state:
		# 1. 發呆結束 -> 準備衝撞，先算好方向再切換
		if player:
			dash_direction = (player.global_position - global_position).normalized()
		else:
			dash_direction = Vector2.RIGHT
		set_state(dash_state)
		print("👹 Boss 決策 -> 鎖定玩家衝撞 (Dash)")
		
	elif state == dash_state:
		# 2. 衝撞結束 -> 切換到全方位射擊
		set_state(shoot_state)
		print("👹 Boss 決策 -> 開始全方位射擊 (Shoot)")
		
	elif state == shoot_state:
		# 3. 射擊結束 -> 回到發呆
		set_state(idle_state)
		print("👹 Boss 決策 -> 休息發呆 (Idle)")

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
			body.take_damage(10) # 衝撞傷害，一次扣 20 滴血！
			print("💥 Boss 撞擊！玩家受到 10 點傷害！")
func die():
	super.die()
	print("💀 Boss死亡！")
	queue_free()
