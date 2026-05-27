# res://Scripts/FSM/CommonState.gd
extends State
class_name CommonState

@export var anim_name: String = ""
@export var is_cycle: bool = true

func enter():
	super.enter()
	
	# 💡 如果是循環狀態，進入時就直接設為可完成（可被中斷）
	if is_cycle:
		is_complete = true

	if core.animator and anim_name != "":
		# 💡 自動同步動畫的 Loop 設定到 SpriteFrames 資源中
		var sf = core.animator.sprite_frames
		if sf and sf.has_animation(anim_name):
			if sf.get_animation_loop(anim_name) != is_cycle:
				sf.set_animation_loop(anim_name, is_cycle)
		
		# 💡 關鍵修復：只有在動畫不同，或是「非循環」狀態（如連招攻擊）時，才重置幀數
		if core.animator.animation != anim_name or not is_cycle:
			core.animator.play(anim_name)
			core.animator.set_frame_and_progress(0, 0.0) 
		else:
			# 如果動畫相同且是循環狀態（如走路中），就繼續播放而不重置幀數
			core.animator.play(anim_name)
		
		if not is_cycle:
			# 連接 AnimatedSprite2D 的訊號
			if not core.animator.animation_finished.is_connected(_on_anim_finished):
				core.animator.animation_finished.connect(_on_anim_finished)
	else:
		is_complete = true

func do_update(_delta: float):
	pass 

func exit():
	super.exit()
	if core.animator and core.animator.animation_finished.is_connected(_on_anim_finished):
		core.animator.animation_finished.disconnect(_on_anim_finished)

# 關鍵修改：AnimatedSprite2D 的訊號沒有 (anim: String) 參數！
func _on_anim_finished(): 
	if not is_cycle:
		is_complete = true
