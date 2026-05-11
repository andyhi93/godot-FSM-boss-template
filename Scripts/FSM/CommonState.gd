# res://Scripts/FSM/CommonState.gd
extends State
class_name CommonState

@export var anim_name: String = ""
@export var is_cycle: bool = true

func enter():
	super.enter()
	if core.animator and anim_name != "":
		core.animator.play(anim_name)
		
		if not is_cycle:
			# 連接 AnimatedSprite2D 的訊號
			if not core.animator.animation_finished.is_connected(_on_anim_finished):
				core.animator.animation_finished.connect(_on_anim_finished)
	else:
		is_complete = true

func do_update(_delta: float):
	if is_cycle:
		is_complete = true 

func exit():
	super.exit()
	if core.animator and core.animator.animation_finished.is_connected(_on_anim_finished):
		core.animator.animation_finished.disconnect(_on_anim_finished)

# 關鍵修改：AnimatedSprite2D 的訊號沒有 (anim: String) 參數！
func _on_anim_finished(): 
	if not is_cycle:
		is_complete = true
