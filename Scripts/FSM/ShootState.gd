# res://Scripts/Boss/ShootState.gd
extends State

var has_fired: bool = false

func enter():
	super.enter()
	has_fired = false # 每次進入狀態時重置開火標記

func fixed_do(_delta: float):
	# 節奏設計：蓄力 0.2 秒後瞬間開火
	if time > 0.2 and not has_fired:
		# 呼叫大腦去扣扳機
		core.shooter.fire_ring(32, 800.0)
		has_fired = true
		
	# 節奏設計：開火後維持帥氣姿勢 1 秒鐘，然後標記動作結束 (0.5 + 1.0 = 1.5)
	if time > 1.5:
		core.start_cd("shoot")
		is_complete = true
