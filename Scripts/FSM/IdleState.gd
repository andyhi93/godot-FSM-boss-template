extends CommonState 

func enter():
	super.enter()
	core.velocity = Vector2.ZERO

func do_update(_delta: float):
	is_complete = true
