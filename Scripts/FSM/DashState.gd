# res://Scripts/Boss/DashState.gd
extends State
func do_update(_delta):
	if time > 1.5: # 蓄力 1.0s + 衝刺 0.5s = 1.5s 標記完成
		is_complete = true
