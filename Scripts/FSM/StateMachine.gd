class_name StateMachine extends RefCounted

var state: State

func set_state(new_state: State, force_reset: bool = false):
	if state != new_state or force_reset or (state and state.is_complete):
		if state:
			state.exit()
		state = new_state
		if state:
			state.initialize(self)
			state.enter()

# 對應你 Unity 的 GetActivesStateBranch
func get_actives_state_branch(list: Array[State] = []) -> Array[State]:
	if state == null:
		return list
	else:
		list.append(state)
		return state.machine.get_actives_state_branch(list)
