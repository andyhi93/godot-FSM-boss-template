extends CharacterBody2D

@export var bullet_scene: PackedScene 

@export var move_speed: float = 300.0
@export var fire_rate: float = 0.15  # 射擊間隔 (秒)，越小射越快

var fire_timer: float = 0.0

# 抓取槍口節點，Godot 4 的神級語法 @onready
@onready var muzzle = $Muzzle 

func _process(delta):
	# 1. 讓角色永遠面向滑鼠游標的位置 (這對後續做動畫很有幫助)
	look_at(get_global_mouse_position())
	
	# 2. 射擊計時器 (計算冷卻時間)
	fire_timer -= delta
	
	# 3. 如果「按住」左鍵，且冷卻完畢，就發射子彈
	if Input.is_action_pressed("shoot") and fire_timer <= 0.0:
		shoot()

func _physics_process(_delta):
	# Godot 4 超好用的神級語法，自動處理 WASD 八方向並正規化 (Normalize)
	# 第一個參數是左，第二個是右，第三是上，第四是下
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = direction * move_speed
	move_and_slide() # Godot 內建的移動與碰撞處理函式

func shoot():
	fire_timer = fire_rate # 重置冷卻時間
	
	# 防呆：如果還沒掛載子彈場景，就先不要執行
	if bullet_scene == null:
		print("還沒放子彈進來喔！")
		return
		
	# 生成子彈實體
	var bullet = bullet_scene.instantiate()
	
	# 把子彈加到目前的遊戲世界裡 (get_tree().root 確保子彈不會跟著玩家一起移動)
	get_tree().root.add_child(bullet)
	
	# 將子彈的位置和旋轉角度，設定得跟「槍口 (Muzzle)」一模一樣
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = muzzle.global_rotation
