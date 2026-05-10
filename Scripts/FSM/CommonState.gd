# res://Scripts/FSM/CommonState.gd
extends State
class_name CommonState

@export var anim_name: String = ""
@export var is_cycle: bool = true

func enter():
	super.enter()
	# 如果有綁定動畫，就播放
	if core.animator and anim_name != "":
		core.animator.play(anim_name)
		
		# 如果是不循環動畫，我們綁定「動畫結束」訊號 (對應 normalizedTime >= 1)
		if not is_cycle:
			if not core.animator.animation_finished.is_connected(_on_anim_finished):
				core.animator.animation_finished.connect(_on_anim_finished)
	else:
		is_complete = true

func do_update(_delta: float):
	if is_cycle:
		is_complete = true # 循環動畫隨時可被中斷

func exit():
	super.exit()
	if core.animator and core.animator.animation_finished.is_connected(_on_anim_finished):
		core.animator.animation_finished.disconnect(_on_anim_finished)

func _on_anim_finished(anim: String):
	if anim == anim_name and not is_cycle:
		is_complete = true
