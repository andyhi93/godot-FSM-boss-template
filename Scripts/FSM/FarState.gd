extends State

func enter():
	super.enter()
	pick_action()

func do_update(_delta: float):
	if machine.state and machine.state.is_complete:
		pick_action()

func pick_action():
	var dash_cd = "dash"
	
	if core.is_phase2():
		# ✅ 二階 → 很躁（更常衝）
		
		if core.is_skill_ready(dash_cd):
			set_state(core.dash_state)
		elif randf() < 0.6:
			set_state(core.dash_state) # 強迫接近
		else:
			is_complete = true
			set_state(core.approach_state)
	else:
		# ✅ 一階 → 正常接近
		
		if core.is_skill_ready(dash_cd):
			set_state(core.dash_state)
		else:
			is_complete = true
			set_state(core.approach_state)
