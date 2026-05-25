extends State

func enter():
	super.enter()
	pick_action()

func do_update(_delta: float):
	if machine.state and machine.state.is_complete:
		pick_action()

func pick_action():
	var shoot_cd = "shoot"
	
	if core.is_phase2():
		# ✅ 二階 → 壓迫射擊 + 更少閒置
		
		if core.is_skill_ready(shoot_cd):
			set_state(core.shoot_state)
		elif randf() < 0.7:
			set_state(core.shoot_state) # 有機率硬開（壓力）
		else:
			is_complete = true
			set_state(core.flank_state)
	else:
		# ✅ 一階 → 比較合理的攻擊節奏
		
		if core.is_skill_ready(shoot_cd):
			set_state(core.shoot_state)
		else:
			is_complete = true
			set_state(core.flank_state)
