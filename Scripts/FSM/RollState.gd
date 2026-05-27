# res://Scripts/FSM/RollState.gd
extends CommonState
class_name RollState

@export var roll_speed: float = 600.0
@export var i_frame_start: int = 1
@export var i_frame_end: int = 4

var roll_direction: Vector2 = Vector2.ZERO

func enter():
	# 1. 決定翻滾方向：優先使用玩家目前的移動輸入，如果沒動，就翻向滑鼠方向或目前的面向
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		roll_direction = input_dir.normalized()
	else:
		# 沒按移動鍵時，翻向滑鼠位置
		var mouse_pos = core.get_global_mouse_position()
		roll_direction = core.global_position.direction_to(mouse_pos)
	
	# 2. 呼叫父類別處理動畫與 Loop 設定
	super.enter()
	
	# 3. 翻滾開始時，先確保無敵是關閉的 (由接下來的 frame 判定)
	core.is_invincible = false

func fixed_do(_delta: float):
	# 持續給予位移速度
	core.velocity = roll_direction * roll_speed
	
	# 🧠 無敵影格判定：檢查目前播放到的動畫幀
	if core.animator:
		var current_frame = core.animator.frame
		if current_frame >= i_frame_start and current_frame <= i_frame_end:
			core.is_invincible = true
		else:
			# 如果不在無敵影格區間，且沒開啟「受傷無敵」，就解除無敵
			# 注意：這裡要小心不要蓋掉「受傷後」產生的無敵
			if core.is_invincible and not core.get("is_manual_invincible"):
				core.is_invincible = false

func exit():
	super.exit()
	core.velocity = Vector2.ZERO
	# 結束時務必解除無敵 (除非受傷無敵還在跑)
	if not core.get("is_manual_invincible"):
		core.is_invincible = false
