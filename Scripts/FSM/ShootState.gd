# res://Scripts/Boss/ShootState.gd
extends CommonState

@export var fire_frame: int = -1 # 如果設為 -1，則在動畫播完才發射
var has_fired: bool = false

func enter():
	super.enter()
	has_fired = false
	is_complete = false
	core.velocity = Vector2.ZERO # 射擊時通常停在原地

func _on_frame_changed(frame: int):
	# 如果有設定特定幀，就在那一幀開火
	if fire_frame != -1 and frame == fire_frame and not has_fired:
		_execute_shoot()

func _on_anim_finished():
	# 如果動畫播完了還沒開火，就在這時候開火（保底或是設計如此）
	if not has_fired:
		_execute_shoot()
	
	super._on_anim_finished()
	core.start_cd("shoot")

func _execute_shoot():
	# 呼叫大腦去扣扳機
	core.shooter.fire_ring(32, 800.0)
	has_fired = true
	# 💡 可以在這裡加入射擊音效
	# AudioManager.play_sfx("Shoot")

func fixed_do(_delta: float):
	# 如果你還是想要一個強制的超時保護，可以保留這個，但通常靠 _on_anim_finished 即可
	if time > 3.0: 
		is_complete = true
