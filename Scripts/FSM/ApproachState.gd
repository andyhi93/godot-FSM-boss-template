extends State

@export var speed: float = 20.0
var dash_direction: Vector2 = Vector2.ZERO

func enter():
	super.enter()
	
func do_update(_delta: float):
	if core.player:
		dash_direction = (core.player.global_position - core.global_position).normalized()
	else:
		dash_direction = Vector2.RIGHT
	
	core.velocity = dash_direction * speed 
		
	if time > 2:
		is_complete = true
func exit():
	core.velocity = Vector2.ZERO
