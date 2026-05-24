extends Core
class_name Player

@export var bullet_scene: PackedScene 
@export var move_speed: float = 300.0
@export var fire_rate: float = 0.15  

var fire_timer: float = 0.0

@onready var weapon_pivot = $WeaponPivot
@onready var gun_sprite = $WeaponPivot/GunSprite
@onready var muzzle = $WeaponPivot/GunSprite/Muzzle

# 抓取狀態積木 (確保節點名稱是小寫的 idle 和 walk)
@onready var idle_state = $States/Idle
@onready var walk_state = $States/Walk

func init_behavior():
	# 💡 防呆報錯 1：檢查狀態節點有沒有掛對
	if idle_state == null:
		push_error("🚨 嚴重錯誤：找不到 idle 狀態節點！請檢查 States 底下是否有叫 'idle' 的節點。")
		return
	
	set_state(idle_state)

func _process(delta):
	if is_dead: return 
	
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

func _physics_process(delta):
	if is_dead: return
	
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	
	# 肉體翻轉邏輯 (單純的視覺表現，留在這裡)
	if animator and direction.x != 0:
		animator.flip_h = direction.x < 0
		
	# 🧠 呼叫大腦決策：玩家是「輸入驅動」，所以我們每一幀都讓大腦思考一次
	select_state()
			
	super._physics_process(delta) 

# --- 🧠 大腦決策區：集中管理所有狀態切換 ---
func select_state():
	# 防禦性程式設計：如果狀態抓不到，直接放棄思考避免遊戲當機
	if idle_state == null or walk_state == null:
		return
		
	var is_moving = velocity != Vector2.ZERO
	
	if is_moving:
		# 如果正在移動，且目前不是 walk 狀態，就切換過去
		if state != walk_state:
			set_state(walk_state)
			#print("🏃 玩家切換狀態 -> Walk") # 幫助學員在 Console 看清狀態流動
	else:
		# 如果沒有移動，且目前不是 idle 狀態，就切換過去
		if state != idle_state:
			set_state(idle_state)
			#print("🧍 玩家切換狀態 -> Idle") 

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

func die():
	super.die()
	print("💀 玩家死亡！")
	queue_free()

func take_damage(damage: int):
	# 1. 檢查是否已經死亡或處於無敵狀態
	if is_dead or is_invincible: return
	
	# 2. 呼叫老爸 (Core) 的扣血邏輯
	super.take_damage(damage)
	
	# 3. 如果被打完還活著，就開啟無敵星星！
	if not is_dead:
		trigger_invincibility(1.5) # 給予 1.5 秒無敵時間

func trigger_invincibility(duration: float):
	is_invincible = true
	
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
	if animator:
		animator.modulate.a = 1.0
