extends CommonState

@export var attack_frame: int = 3    # 觸發攻擊判定在那一幀
@export var stun_time: float = 1.0 # 總共要在這狀態待多久 (如果不想等動畫播完)
@export var tracking_speed: float = 150.0 # 攻擊前微調位置的速度
@export var attack_range: float = 120.0   # 攻擊範圍

var has_attacked: bool = false

func enter():
	super.enter()
	has_attacked = false
	is_complete = false
	core.velocity = Vector2.ZERO 
	
	if core.is_phase2(): 
		stun_time = 0.5

func _on_frame_changed(frame: int):
	# 當動畫播放到指定的一幀時，發射劍氣！
	if frame == attack_frame and not has_attacked:
		core.execute_melee_attack()
		has_attacked = true
		core.velocity = Vector2.ZERO # 攻擊瞬間停下
		
		# 💡 如果有寫音效系統，也可以在這裡播放
		# AudioManager.play_sfx("Slash")

func fixed_do(_delta: float):
	# 只要還沒發出攻擊，就持續追蹤玩家（微調位置）
	if not has_attacked:
		if is_instance_valid(core.player):
			var dist = core.global_position.distance_to(core.player.global_position)
			if dist > attack_range:
				var dir = core.global_position.direction_to(core.player.global_position)
				core.velocity = dir * tracking_speed
			else:
				core.velocity = Vector2.ZERO
		else:
			core.velocity = Vector2.ZERO
	
	# 如果你希望狀態在一定時間後強制結束 (保底機制)
	if time > stun_time:
		core.start_cd("melee")
		is_complete = true

# 你也可以選擇在動畫播放完畢後才結束狀態
func _on_anim_finished():
	super._on_anim_finished() # 如果 auto_complete 開啟，這裡會把 is_complete 設為 true
	core.start_cd("melee")

func exit():
	super.exit()
	core.velocity = Vector2.ZERO
