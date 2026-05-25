extends State

@export var windup_time: float = 1.0
@export var dash_duration: float = 0.5
@export var minimum_dist: float = 800.0 
@export var overshoot_offset: float = 150.0  
@export var dash_curve: Curve  

var dash_direction: Vector2 = Vector2.ZERO
var total_target_dist: float = 0.0
var last_curve_val: float = 0.0

# 新增：紀錄衝刺啟動時的關鍵座標與狀態
var dash_start_pos: Vector2 = Vector2.ZERO
var has_initialized_dash: bool = false

func enter():
	super.enter()
	last_curve_val = 0.0
	dash_start_pos = Vector2.ZERO
	has_initialized_dash = false
	dash_direction = Vector2.RIGHT # 防呆預設值
	
	# 進入狀態時先做第一次情報更新
	_update_target_info_during_windup()
	print("time: ",time)

func fixed_do(delta: float):
	
	# ✅ 1. 前搖蓄力階段：每個物理幀都在瘋狂重新鎖定玩家的最新位置
	if time < windup_time:
		core.velocity = Vector2.ZERO
		_update_target_info_during_windup()
		
	# ✅ 2. 衝刺爆發階段
	elif time < windup_time + dash_duration:
		# 【關鍵轉折點】衝刺開始的第一幀，立刻死鎖當下的 Boss 位置作為「衝刺起點」
		if not has_initialized_dash:
			dash_start_pos = core.global_position
			has_initialized_dash = true
		
		# 衝刺中：方向已經死鎖（不更新 dash_direction），但「動態更新目標距離」！
		if is_instance_valid(core.player):
			# 計算玩家目前相對於衝刺起點的位移向量
			var to_player = core.player.global_position - dash_start_pos
			
			# 核心數學魔術：使用 dot() 將位移向量投影到衝刺方向上
			# 這會算出玩家在「衝刺軸向」上目前前進了多少像素，完全無視左右橫移！
			var projected_dist = to_player.dot(dash_direction)
			
			# 新的動態總距離 = 玩家在軸向上的最新距離 + 衝過頭的偏移量
			var desired_dist = projected_dist + overshoot_offset
			
			# 保底機制
			total_target_dist = max(minimum_dist, desired_dist)
		
		# 算出目前的物理時間進度 (0.0 到 1.0 之間)
		var progress = (time - windup_time) / dash_duration
		
		if dash_curve != null:
			var current_curve_val = dash_curve.sample(progress)
			var curve_delta = current_curve_val - last_curve_val
			last_curve_val = current_curve_val
			
			# 根據每一幀被玩家動態拉長（或縮短）的 total_target_dist，實時計算出當前速度
			core.velocity = dash_direction * (total_target_dist * curve_delta) / delta
		else:
			# 沒畫曲線時的防呆等速衝刺
			core.velocity = dash_direction * (total_target_dist / dash_duration)
			
	# ✅ 3. 結束階段
	else:
		print("time: ",time)
		core.start_cd("dash")
		is_complete = true

func exit():
	core.velocity = Vector2.ZERO

# 抽出來的專用函式：蓄力期間專用，同時咬住方向與最新預期距離
func _update_target_info_during_windup():
	if is_instance_valid(core.player):
		var my_pos = core.global_position
		var player_pos = core.player.global_position
		
		# 蓄力期：方向跟隨玩家轉動
		dash_direction = my_pos.direction_to(player_pos)
		
		# 蓄力期：精準計算兩者間的直線距離
		var dist_to_player = my_pos.distance_to(player_pos)
		var desired_dist = dist_to_player + overshoot_offset
		total_target_dist = max(minimum_dist, desired_dist)
