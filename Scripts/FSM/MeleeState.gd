extends State

var has_slashed: bool = false

func enter():
	super.enter()
	has_slashed = false
	core.velocity = Vector2.ZERO # 揮刀前先強制定住不動

func do_update(_delta):
	# 蓄力前搖：經過 0.5 秒後，才真正呼叫大腦生成劍氣
	if time > 0.5 and not has_slashed:
		core.execute_melee_attack()
		has_slashed = true
		
	# 收招硬直：揮刀後再停留 0.5 秒 (總共 1.0 秒)，才結束這個狀態
	if time > 1.0:
		core.start_cd("melee")
		is_complete = true
