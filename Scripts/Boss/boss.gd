extends Core
class_name Boss

@onready var idle_state: State = $States/Idle
@onready var dash_state: State = $States/Dash

var player: Node2D
var dash_direction: Vector2 = Vector2.ZERO

func init_behavior():
	player = get_tree().get_first_node_in_group("Player")
	set_state(idle_state)

func _physics_process(delta):
	if is_dead: return
	
	# --- 🏃 物理行為區 ---
	# TODO: 請根據目前的狀態 (state) 來設定 velocity (速度)
	# 例如：Idle 時速度為 0，Dash 時根據 dash_direction 移動
	
	super._physics_process(delta) 

# --- 🧠 大腦決策區 ---
func select_state():
	# 檢查狀態是否都已定義
	if idle_state == null or dash_state == null:
		return
		
	# 檢查目前的狀態是否執行完畢 (is_complete)
	if not state.is_complete: 
		return

	# TODO: 請在此處實作 Boss 的狀態切換流程
	# 例如：如果目前是 idle，就計算衝刺方向並切換到 dash
	# 如果目前是 dash，就切回 idle

# 當玩家撞進 Boss 的攻擊範圍時觸發
func _on_damage_aura_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(2)
		print("💥 Boss 擊中玩家！")

func die():
	super.die()
	queue_free()
