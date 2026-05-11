extends Area2D

@export var speed: float = 600.0
@export var damage: int = 10
@export var target_group: String = "Enemy" 

# 開放給學員自定義的參數
@export var lifespan: float = 2.0     # 新增：子彈存活時間
@export var curve_speed: float = 0.0  # 弧線轉向速度
@export var wobble_amp: float = 0.0   # S 型蛇行的幅度
@export var wobble_freq: float = 10.0 # S 型蛇行的頻率

var alive_time: float = 0.0 

func _ready():
	# 使用開放出來的 lifespan 變數來決定壽命
	await get_tree().create_timer(lifespan).timeout
	queue_free()

func _physics_process(delta):
	alive_time += delta
	rotation += curve_speed * delta 
	
	var forward_dir = Vector2.RIGHT.rotated(rotation)
	var wobble_offset = forward_dir.rotated(PI/2) * sin(alive_time * wobble_freq) * wobble_amp
	
	position += (forward_dir * speed + wobble_offset) * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
