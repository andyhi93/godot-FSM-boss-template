extends Marker2D
class_name Shooter

# 讓學生可以直接在 Inspector 拖曳子彈場景進來
@export var bullet_scene: PackedScene

# 招式：全方位圓形彈幕 (Ring of Death)
func fire_ring(bullet_count: int, bullet_speed: float):
	if bullet_scene == null: return
	var angle_step = TAU / bullet_count 
	
	for i in range(bullet_count):
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position
		bullet.rotation = i * angle_step
		bullet.speed = bullet_speed
		
		if i % 2 == 0:
			bullet.curve_speed = 0.5
		else:
			bullet.curve_speed = -0.5
		
		# Boss 射出的子彈，目標設定為打玩家
		bullet.target_group = "Player"
