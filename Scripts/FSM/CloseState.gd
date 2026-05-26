extends State

func enter():
	super.enter()
	pick_action()

func do_update(_delta: float):
	# 子狀態做完再選下一個
	if machine.state and machine.state.is_complete:
		pick_action()

func pick_action():
	# ✅ Phase 影響（加速節奏）
	var melee_cd = "melee"
	
	if core.is_phase2():
		# 二階 → 更兇（CD 更短，或幾乎一直砍）
		if core.is_skill_ready(melee_cd) or randf() < 0.4:
			set_state(core.melee_state)
		else:
			if machine.state == core.retreat_state:
				is_complete = true
			else:
				set_state(core.retreat_state)
	else:
		# 一階 → 比較保守
		if core.is_skill_ready(melee_cd):
			set_state(core.melee_state)
		else:
			if machine.state == core.retreat_state:
				is_complete = true
			else:
				set_state(core.retreat_state)
