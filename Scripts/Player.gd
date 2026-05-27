extends Core
class_name Player

@export var bullet_scene: PackedScene 
@export var move_speed: float = 300.0
@export var fire_rate: float = 0.15  

var fire_timer: float = 0.0

@onready var weapon_pivot = $WeaponPivot
@onready var gun_sprite = $WeaponPivot/GunSprite
@onready var muzzle = $WeaponPivot/GunSprite/Muzzle

#近戰相關與硬直開關
@export var slash_scene: PackedScene
@export var slash_offset: float = 40.0
@export var slash_scale: Vector2 = Vector2(1, 1)
@export var lock_movement_on_melee: bool = false # 決定揮刀時會不會定在原地
@export var enable_hit_invincibility: bool = true # 是否開啟受傷後的暫時無敵
var isMeleeing: bool = false
var isRolling: bool = false
var is_manual_invincible: bool = false # 用來區分「受傷無敵」與「翻滾無敵」

# 抓取狀態積木 (確保節點名稱是小寫的 idle 和 walk)
@onready var idle_state = $States/Idle
@onready var walk_state = $States/Walk
@onready var melee_state = $States/Melee
@onready var roll_state = get_node_or_null("States/Roll")

func init_behavior():
	# 💡 防呆報錯 1：檢查狀態節點有沒有掛對
	if idle_state == null:
		push_error("🚨 嚴重錯誤：找不到 idle 狀態節點！請檢查 States 底下是否有叫 'idle' 的節點。")
		return
	
	set_state(idle_state)

func _process(delta):
	super._process(delta)
	if is_dead: return 
	
	#狀態Debug
	if show_state_debug: queue_redraw()
	
	# 💡 防呆報錯 2：檢查武器節點是否健在
	if weapon_pivot and gun_sprite:
		var mouse_pos = get_global_mouse_position()
		weapon_pivot.look_at(mouse_pos)
		gun_sprite.flip_v = mouse_pos.x < weapon_pivot.global_position.x
	else:
		push_warning("⚠️ 警告：找不到武器節點 (WeaponPivot 或 GunSprite)，請檢查節點結構！")
	
	fire_timer -= delta
	if Input.is_action_pressed("shoot") and fire_timer <= 0.0:
		shoot()

	if not isMeleeing and not isRolling and Input.is_action_just_pressed("melee"):
		isMeleeing = true
		execute_melee_attack()
		
	if not isRolling and Input.is_action_just_pressed("roll"): # 預設用空白鍵(Space)
		isRolling = true

func _physics_process(delta):
	if is_dead: return
	
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 如果正在近戰狀態，且開啟了硬直開關，就將速度歸零；否則照常移動
	if state == melee_state and lock_movement_on_melee:
		velocity = Vector2.ZERO
	elif state == roll_state:
		pass # 速度由 RollState 控制
	else:
		velocity = direction * move_speed
	
	# 肉體翻轉邏輯 (單純的視覺表現，留在這裡)
	if animator and direction.x != 0 and state != roll_state:
		animator.flip_h = direction.x < 0
			
	super._physics_process(delta) 

# --- 🧠 大腦決策區：集中管理所有狀態切換 ---
func select_state():
	# 💡 新增：如果當前狀態還沒完成 (例如揮刀或翻滾中)，就先不要切換
	if state and not state.is_complete:
		return

	# 防禦性程式設計：如果狀態抓不到，直接放棄思考避免遊戲當機
	if idle_state == null or walk_state == null or melee_state == null:
		return
	
	if state == melee_state:
		isMeleeing = false # 解除近戰鎖定
		
	if state == roll_state:
		isRolling = false

	if isRolling and roll_state != null:
		set_state(roll_state)
		return

	if isMeleeing:
		set_state(melee_state)
		return
	var is_moving = velocity != Vector2.ZERO
	if is_moving:
		set_state(walk_state)
	else:
		set_state(idle_state)

func shoot():
	# 💡 防呆報錯 3：新手最常忘記把子彈場景拖曳到 Inspector！
	if bullet_scene == null: 
		push_error("🚨 錯誤：玩家沒有裝備子彈！請點擊 Player 節點，去右邊 Inspector 把 Bullet Scene 拖進去。")
		return
		
	fire_timer = fire_rate
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	
	# 💡 防呆報錯 4：槍口節點遺失
	if muzzle:
		bullet.global_position = muzzle.global_position
		bullet.global_rotation = muzzle.global_rotation
	else:
		push_error("🚨 錯誤：找不到發射槍口 (Muzzle) 節點！")
	
	bullet.target_group = "Enemy"

# --- 近戰攻擊指令 ---
func execute_melee_attack():
	if slash_scene == null:
		push_error("🚨 忘記把 MeleeAura.tscn 拖進 Player 的 Slash Scene 欄位了！")
		return

	var slash = slash_scene.instantiate()
	
	# 1. 抓取滑鼠在遊戲世界中的真實座標
	var mouse_pos = get_global_mouse_position()
	
	# 2. 計算玩家到「滑鼠游標」的方向向量
	var dir = global_position.direction_to(mouse_pos)

	# 3. 設定位置 = 玩家中心點 + (方向向量 * 偏移距離)
	slash.global_position = global_position + (dir * slash_offset)

	# 4. 設定旋轉角度 (面向滑鼠)
	slash.rotation = dir.angle() - (PI / 2.0)
	
	slash.scale = slash_scale
	
	# 💡 確保玩家揮出的劍氣目標是敵人，避免自傷
	slash.target_group = "Enemy" 
	
	get_parent().add_child(slash)

func die():
	super.die()
	print("💀 玩家死亡！")
	queue_free()

func take_damage(damage: int):
	# 1. 檢查是否已經死亡或處於無敵狀態
	if is_dead or is_invincible: return
	
	# 2. 呼叫老爸 (Core) 的扣血邏輯
	super.take_damage(damage)
	
	# 3. 如果開啟了受傷無敵，且被打完還活著，就開啟無敵星星！
	if enable_hit_invincibility and not is_dead:
		trigger_invincibility(1.5) # 給予 1.5 秒無敵時間

func trigger_invincibility(duration: float):
	is_invincible = true
	is_manual_invincible = true # 標記這是由程式手動開啟的無敵
	
	# 🌟 魔法指令：使用 Tween 製作程式碼動畫
	var tween = create_tween()
	
	# 設定迴圈次數 (例如 1.5 秒 * 10 = 閃爍 15 次)
	tween.set_loops(int(duration * 10)) 
	
	if animator:
		# 讓透明度 (alpha) 在 0.2 和 1.0 之間來回切換，每次 0.05 秒
		tween.tween_property(animator, "modulate:a", 0.2, 0.05)
		tween.tween_property(animator, "modulate:a", 1.0, 0.05)
	
	# 等待無敵時間結束
	await get_tree().create_timer(duration).timeout
	
	# 解除無敵，並確保透明度恢復 100% 正常
	is_invincible = false
	is_manual_invincible = false
	if animator:
		animator.modulate.a = 1.0
