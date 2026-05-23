extends State

@export var speed: float = 800.0
var dash_direction: Vector2 = Vector2.ZERO

func enter():
	super.enter()
	
	if core.player:
		dash_direction = (core.player.global_position - core.global_position).normalized()
	else:
		dash_direction = Vector2.RIGHT

func do_update(_delta: float):
	
	# ✅ 前搖（1 秒）
	if time < 1.0:
		core.velocity = Vector2.ZERO
	
	# ✅ 衝刺
	else:
		core.velocity = dash_direction * speed 
		
	# ✅ 1.5 秒後結束
	if time > 1.5:
		is_complete = true
func exit():
	core.velocity = Vector2.ZERO
