extends Node

# --- 相機控制管理器 (CameraManager) ---
var trauma: float = 0.0
@export var trauma_power: float = 2.0
@export var max_offset: Vector2 = Vector2(50, 50)
@export var max_roll: float = 5.0
@export var trauma_decay: float = 0.8
@export var time_scale: float = 15.0

var noise = FastNoiseLite.new()
var noise_y: float = 0
var current_camera: Camera2D = null # 目前正在受管理的相機

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	noise.seed = randi()
	noise.frequency = 0.5

# 讓外部節點（如 Player）主動把自己身上的相機交給管理器
func set_camera(camera: Camera2D):
	current_camera = camera

# 取得目前正在使用的相機 (如果沒人主動交，就自己抓場景裡的)
func get_active_camera() -> Camera2D:
	if is_instance_valid(current_camera):
		return current_camera
	
	var cam = get_viewport().get_camera_2d()
	if cam:
		current_camera = cam
		return cam
	return null

func add_trauma(amount: float):
	trauma = clamp(trauma + amount, 0.0, 1.0)

func shake(strength: float = 0.5):
	add_trauma(strength)

func hit_stop(duration: float = 0.1, time_scale_val: float = 0.01):
	Engine.time_scale = time_scale_val
	await get_tree().create_timer(duration * time_scale_val).timeout
	Engine.time_scale = 1.0

func zoom_to(target_zoom: float, duration: float = 0.5):
	var camera = get_active_camera()
	if camera:
		var tween = create_tween()
		tween.tween_property(camera, "zoom", Vector2(target_zoom, target_zoom), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _process(delta):
	var camera = get_active_camera()
	if not camera: return

	if trauma > 0:
		trauma = max(trauma - trauma_decay * delta, 0)
		var shake_val = pow(trauma, trauma_power)
		noise_y += delta * time_scale
		
		# 使用 offset 來震動，這樣不會干擾相機本身的 position (跟隨玩家的座標)
		camera.offset.x = max_offset.x * shake_val * noise.get_noise_2d(666, noise_y)
		camera.offset.y = max_offset.y * shake_val * noise.get_noise_2d(999, noise_y)
		camera.rotation_degrees = max_roll * shake_val * noise.get_noise_2d(333, noise_y)
	else:
		camera.offset = lerp(camera.offset, Vector2.ZERO, 0.1)
		camera.rotation_degrees = lerp(camera.rotation_degrees, 0.0, 0.1)
