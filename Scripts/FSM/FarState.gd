extends State

func enter():
	super.enter()
	pick_action()
	print("Far iscomplete: ",is_complete)

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
			if machine.state == core.approach_state:
				is_complete = true
			else:
				set_state(core.approach_state)
	else:
		# ✅ 一階 → 正常接近
		
		if core.is_skill_ready(dash_cd):
			set_state(core.dash_state)
		else:
			if machine.state == core.approach_state:
				is_complete = true
			else:
				set_state(core.approach_state)
