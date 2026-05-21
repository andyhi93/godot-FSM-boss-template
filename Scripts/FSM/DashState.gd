extends State

var dash_direction: Vector2 = Vector2.ZERO

func enter():
	super.enter()
	# 💡 已經幫你算好衝撞方向了！(向量數學較複雜，這裡先幫你寫好)
	if core.player:
		dash_direction = (core.player.global_position - core.global_position).normalized()
	else:
		dash_direction = Vector2.RIGHT

#func do_update(_delta: float):
	
	# --- 🏃 肉體執行區 ---
	# TODO 1：設計衝撞節奏
	# 如果時間 (time) 小於 1.0 秒：
		# 讓 core.velocity 等於 Vector2.ZERO (原地蓄力前搖)
	# 否則 (代表時間大於 1.0 秒)：
		# 讓 core.velocity 等於 dash_direction 乘上 800.0 (高速衝刺！)
		
	
	
	# --- ⏱️ 任務結算區 ---
	# TODO 2：如果時間超過 1.5 秒 (蓄力 1.0s + 衝刺 0.5s)，標記任務完成
