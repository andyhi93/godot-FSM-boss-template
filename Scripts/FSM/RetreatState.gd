extends State

@export var retreat_duration: float = 0.4   # 後撤跳躍的時間 (通常比衝刺短，講求俐落)
@export var retreat_distance: float = 250.0 # 要往後跳多遠
@export var retreat_curve: Curve            # 用來畫出「後撤跳躍」手感的曲線

var retreat_dir: Vector2 = Vector2.ZERO
var last_curve_val: float = 0.0

func enter():
	super.enter()
	last_curve_val = 0.0
	
	# 鎖定後撤方向：從玩家指向 Boss 的方向 (即遠離玩家)
	if is_instance_valid(core.player):
		var my_pos = core.global_position
		var player_pos = core.player.global_position
		retreat_dir = player_pos.direction_to(my_pos) 
	else:
		retreat_dir = Vector2.LEFT

func fixed_do(delta: float):
	if time < retreat_duration:
		# 算出目前的物理時間進度 (0.0 到 1.0 之間)
		var progress = time / retreat_duration
		
		if retreat_curve != null:
			var current_curve_val = retreat_curve.sample(progress)
			var curve_delta = current_curve_val - last_curve_val
			last_curve_val = current_curve_val
			
			# 根據曲線進度分配這幀該跳的距離
			core.velocity = retreat_dir * (retreat_distance * curve_delta) / delta
		else:
			# 防呆等速後撤
			core.velocity = retreat_dir * (retreat_distance / retreat_duration)
	else:
		# 跳完落地，結束狀態
		is_complete = true

func exit():
	super.exit()
	core.velocity = Vector2.ZERO
