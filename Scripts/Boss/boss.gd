# res://Scripts/Boss/boss.gd
extends Core
class_name Boss

@onready var idle_state: State = $States/Idle
@onready var dash_state: State = $States/Dash

var player: Node2D
var dash_direction: Vector2 = Vector2.ZERO

func init_behavior():
	player = get_tree().get_first_node_in_group("Player")
	set_state(idle_state)

# 大腦決策：切換狀態
func select_state():
	if state == idle_state:
		# 準備換 Dash，先算好方向
		if player:
			dash_direction = (player.global_position - global_position).normalized()
		else:
			dash_direction = Vector2.RIGHT
		set_state(dash_state)
		
	elif state == dash_state:
		set_state(idle_state)

# 大腦執行：控制物理與速度
func _physics_process(delta):
	# 這裡一樣會執行 state 的邏輯跟 move_and_slide
	super._physics_process(delta) 
	if is_dead: return
	
	if state == idle_state:
		velocity = Vector2.ZERO # 發呆時停住
		
	elif state == dash_state:
		# 利用 state 內建的 time 來決定物理行為
		if state.time < 1.0:
			velocity = Vector2.ZERO # 蓄力前搖 (停住)
		else:
			velocity = dash_direction * 800.0 # 衝刺！
