extends CommonState

@export var windup_time: float = 1.0 # 蓄力階段
@export var dash_duration: float = 0.5 # 衝刺時間長度
@export var minimum_dist: float = 800.0  # 最小衝刺距離
@export var overshoot_offset: float = 150.0  # 要超過玩家多少距離
@export var dash_curve: Curve  # 變速曲線

var dash_direction: Vector2 = Vector2.ZERO
var total_target_dist: float = 0.0
var last_curve_val: float = 0.0

# 紀錄衝刺啟動時的關鍵座標與狀態
var dash_start_pos: Vector2 = Vector2.ZERO
var has_initialized_dash: bool = false
var indicator: Node2D = null # 新增區域變數來存放 indicator

func enter():
	super.enter()
	last_curve_val = 0.0
	dash_start_pos = Vector2.ZERO
	has_initialized_dash = false
	dash_direction = Vector2.RIGHT # 防呆預設值
	
	indicator = core.get_node_or_null("DashIndicator")
	if indicator:
		indicator.show()
	
	# 進入狀態時先做第一次情報更新
	_update_target_info_during_windup()

func fixed_do(delta: float):
	# ✅ 1. 前搖蓄力階段：鎖定玩家位置並更新提示線
	if time < windup_time:
		core.velocity = Vector2.ZERO
		_update_target_info_during_windup()
		
		# 更新提示線
		if indicator:
			indicator.rotation = dash_direction.angle()
			# 設定 Line2D 的第二個點，長度等於衝刺距離
			if indicator.has_method("set_point_position"):
				indicator.set_point_position(1, Vector2(total_target_dist, 0))
		
	# ✅ 2. 衝刺爆發階段
	elif time < windup_time + dash_duration:
		# 衝刺開始瞬間隱藏提示線
		if indicator and indicator.visible:
			indicator.hide()
			
		# 【關鍵轉折點】衝刺開始的第一幀，立刻死鎖當下的 Boss 位置作為「衝刺起點」
		if not has_initialized_dash:
			dash_start_pos = core.global_position
			has_initialized_dash = true
		
		# 衝刺中：方向已經死鎖，但「動態更新目標距離」
		if is_instance_valid(core.player):
			var to_player = core.player.global_position - dash_start_pos
			var projected_dist = to_player.dot(dash_direction)
			var desired_dist = projected_dist + overshoot_offset
			total_target_dist = max(minimum_dist, desired_dist)
		
		# 物理進度處理
		var progress = (time - windup_time) / dash_duration
		if dash_curve != null:
			var current_curve_val = dash_curve.sample(progress)
			var curve_delta = current_curve_val - last_curve_val
			last_curve_val = current_curve_val
			core.velocity = dash_direction * (total_target_dist * curve_delta) / delta
		else:
			core.velocity = dash_direction * (total_target_dist / dash_duration)
			
	# ✅ 3. 結束階段
	else:
		core.start_cd("dash")
		is_complete = true

func exit():
	super.exit()
	core.velocity = Vector2.ZERO
	if indicator:
		indicator.hide()

# 蓄力期間專用：同步更新方向與預期距離
func _update_target_info_during_windup():
	if is_instance_valid(core.player):
		var my_pos = core.global_position
		var player_pos = core.player.global_position
		
		dash_direction = my_pos.direction_to(player_pos)
		var dist_to_player = my_pos.distance_to(player_pos)
		var desired_dist = dist_to_player + overshoot_offset
		total_target_dist = max(minimum_dist, desired_dist)
