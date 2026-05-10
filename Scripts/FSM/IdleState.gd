# res://Scripts/Boss/IdleState.gd
extends State  
func do_update(_delta):
	if time > 2.0: # 時間大於兩秒，標記完成
		is_complete = true
