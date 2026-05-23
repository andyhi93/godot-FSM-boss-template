extends State

func do_update(_delta: float):
	
	# ✅ 停止移動
	core.velocity = Vector2.ZERO
	
	# ✅ 2 秒結束
	if time > 2.0: 
		is_complete = true
