extends State

@export var flank_speed: float = 250.0
@export var target_distance: float = 300.0 # Boss 想要保持的繞圈半徑
@export var duration: float = 3.0          # 迂迴要持續幾秒
var orbit_direction: int = 1               # 1 = 順時針, -1 = 逆時針

func enter():
	super.enter()
	# 每次進入迂迴狀態時，擲骰子隨機決定要順時針還是逆時針繞！
	# 這樣玩家才抓不到規律
	orbit_direction = 1 if randf() > 0.5 else -1

func fixed_do(_delta: float):
	# 防呆：如果玩家死掉或不見了，就停在原地
	if not is_instance_valid(core.player):
		core.velocity = Vector2.ZERO
		return
		
	# 取得 Boss 到玩家的基礎情報
	var dir_to_player = core.global_position.direction_to(core.player.global_position)
	var current_dist = core.global_position.distance_to(core.player.global_position)
	
	# 力量 A：切線方向 (繞圈圈的動力)
	# 將指向玩家的向量旋轉 90 度 (PI / 2 弧度)
	var tangent_dir = dir_to_player.rotated((PI / 2.0) * orbit_direction)
	
	# 力量 B：距離修正 (保持完美的圓形軌道)
	# 如果單純只用切線繞圈，經過幾個物理幀後 Boss 的軌跡會慢慢變成往外飛的螺旋線
	var distance_error = current_dist - target_distance
	
	var move_dir = tangent_dir
	
	# 設定一個容錯區間（例如差距大於 20 像素才開始修正）
	if abs(distance_error) > 20.0:
		# distance_error 若為正數（太遠），sign 會回傳 1，Boss 會稍微往玩家靠近
		# distance_error 若為負數（太近），sign 會回傳 -1，Boss 會稍微往後退
		var correction_dir = dir_to_player * sign(distance_error)
		
		# 將「切線轉圈」與「距離修正」兩個力量融合，並重新歸一化 (保持速度一致)
		move_dir = (tangent_dir + correction_dir * 0.5).normalized()
	
	# 寫入物理速度
	core.velocity = move_dir * flank_speed
	
	# 迂迴通常是用來「等待下一波攻擊時機」，時間到了就標記完成
	if time > duration:
		is_complete = true

func exit():
	super.exit()
	# 結束狀態時踩煞車
	core.velocity = Vector2.ZERO
