extends Node
class_name State

var core: Core
var is_complete: bool = false

# 對應你的 time => Time.time - startTime
var start_time: float = 0.0
var time: float:
	get: return (Time.get_ticks_msec() / 1000.0) - start_time

var machine: StateMachine
var parent: StateMachine

func set_core(_core: Core):
	machine = StateMachine.new() # 初始化自己的子狀態機
	core = _core

func initialize(_parent: StateMachine):
	parent = _parent
	is_complete = false
	start_time = Time.get_ticks_msec() / 1000.0

# --- 虛擬函式 ---
func enter():
	if(core.name=="Boss"): print(core.name+": "+name)
func do_update(_delta: float): pass
func fixed_do(_delta: float): pass
func exit(): pass

# --- 階層式分發 (對應 DoBranch / FixedDoBranch) ---
func do_branch(delta: float):
	do_update(delta)
	if machine and machine.state:
		machine.state.do_branch(delta)

func fixed_do_branch(delta: float):
	fixed_do(delta)
	if machine and machine.state:
		machine.state.fixed_do_branch(delta)

# 給子狀態切換用的捷徑
func set_state(new_state: State, force_reset: bool = false):
	machine.set_state(new_state, force_reset)
