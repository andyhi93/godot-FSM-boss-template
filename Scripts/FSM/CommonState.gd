# res://Scripts/FSM/CommonState.gd
extends State
class_name CommonState

@export var anim_name: String = ""
@export var is_cycle: bool = true
@export var auto_complete: bool = true # 是否由動畫自動決定狀態完成

func enter():
	super.enter()
	
	# 💡 如果開啟自動完成，且是循環狀態，進入時就直接設為可完成
	if auto_complete and is_cycle:
		is_complete = true

	if core.animator and anim_name != "":
		# 自動同步動畫的 Loop 設定到 SpriteFrames 資源中
		var sf = core.animator.sprite_frames
		if sf and sf.has_animation(anim_name):
			if sf.get_animation_loop(anim_name) != is_cycle:
				sf.set_animation_loop(anim_name, is_cycle)
		
		# 只有在動畫不同，或是「非循環」狀態時，才重置幀數
		if core.animator.animation != anim_name or not is_cycle:
			core.animator.play(anim_name)
			core.animator.set_frame_and_progress(0, 0.0) 
		else:
			# 如果動畫相同且是循環狀態，就繼續播放而不重置幀數
			core.animator.play(anim_name)
		
		if not is_cycle:
			# 連接 AnimatedSprite2D 的訊號
			if not core.animator.animation_finished.is_connected(_on_anim_finished):
				core.animator.animation_finished.connect(_on_anim_finished)
		
		# 新增：連接幀切換訊號，方便在特定幀執行程式碼
		if not core.animator.frame_changed.is_connected(_internal_on_frame_changed):
			core.animator.frame_changed.connect(_internal_on_frame_changed)
	else:
		# 如果沒有動畫機或沒給名字，且開啟自動完成，就視為完成
		if auto_complete:
			is_complete = true

func do_update(_delta: float):
	pass 

func exit():
	super.exit()
	if core.animator:
		if core.animator.animation_finished.is_connected(_on_anim_finished):
			core.animator.animation_finished.disconnect(_on_anim_finished)
		if core.animator.frame_changed.is_connected(_internal_on_frame_changed):
			core.animator.frame_changed.disconnect(_internal_on_frame_changed)

# --- 虛擬函式：可由子類別覆寫 ---

# 當幀切換時觸發 (可用來在特定幀產生攻擊判定)
func _on_frame_changed(frame: int):
	pass

# 當非循環動畫播放完畢時觸發
func _on_anim_finished(): 
	if auto_complete and not is_cycle:
		is_complete = true

# --- 內部邏輯 ---
func _internal_on_frame_changed():
	if core.animator:
		_on_frame_changed(core.animator.frame)
