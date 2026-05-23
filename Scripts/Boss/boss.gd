extends Core
class_name Boss

@onready var idle_state: State = $States/Idle
@onready var dash_state: State = $States/Dash

var player: Node2D
var dash_direction: Vector2 = Vector2.ZERO

func init_behavior():
	player = get_tree().get_first_node_in_group("Player")
	set_state(idle_state)

func select_state():
	# 防呆
	if idle_state == null or dash_state == null:
		return
		
	if not state.is_complete:
		return

	# ✅ 狀態切換
	if state == idle_state:
		set_state(dash_state)
		print("👹 Boss 決策：衝刺")
	elif state == dash_state:
		set_state(idle_state)
		print("👹 Boss 決策：發呆")

func _on_damage_aura_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		body.take_damage(2)

func die():
	super.die()
	queue_free()
