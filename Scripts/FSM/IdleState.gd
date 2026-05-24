extends State 

func do_update(_delta: float):
	is_complete = true
	# ✅ 停止移動
	core.velocity = Vector2.ZERO
