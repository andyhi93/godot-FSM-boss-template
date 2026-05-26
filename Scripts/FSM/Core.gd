# res://Scripts/FSM/Core.gd
extends CharacterBody2D
class_name Core

@export var max_hp: int = 100
var current_hp: int
var is_dead: bool = false
var is_invincible: bool = false

@onready var rb: CharacterBody2D = self 
@onready var animator: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var machine: StateMachine
var state: State:
	get: return machine.state if machine else null

@export var show_state_debug: bool = true
var debug_font: Font = ThemeDB.fallback_font

func _ready():
	if Engine.is_editor_hint():
		return
		
	current_hp = max_hp
	set_up_instances()
	init_behavior() # 留給子類別 (Boss/Player) 實作
	
	if is_in_group("Player"):
		UIManager.update_player_hp(current_hp, max_hp)
	elif is_in_group("Enemy"):
		UIManager.update_boss_hp(current_hp, max_hp)

func set_up_instances():
	machine = StateMachine.new()
	# Godot 遞迴尋找所有繼承自 State 的子節點 (對應 GetComponentsInChildren)
	var all_child_states = find_children("*", "State", true, false)
	for s in all_child_states:
		s.set_core(self)

func set_state(new_state: State, force_reset: bool = false):
	machine.set_state(new_state, force_reset)

func _process(delta):
	if Engine.is_editor_hint():
		return
		
	if is_dead: return
	
	if state and state.is_complete:
		select_state()
		queue_redraw()
		
	if machine and machine.state:
		machine.state.do_branch(delta)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
		
	if is_dead: return
	
	if machine and machine.state:
		machine.state.fixed_do_branch(delta)
	
	move_and_slide() # 統一在這裡執行物理移動

# --- 虛擬函式 ---
func init_behavior(): pass
func select_state(): pass

# --- 戰鬥基礎 ---
func take_damage(damage: int):
	if is_dead or is_invincible: return
	current_hp = clampi(current_hp - damage, 0, max_hp)
	
	if is_in_group("Player"):
		UIManager.update_player_hp(current_hp, max_hp)
	elif is_in_group("Enemy"):
		UIManager.update_boss_hp(current_hp, max_hp)
	
	if current_hp <= 0:
		die()

func die():
	is_dead = true
	
	if is_in_group("Player"):
		UIManager.show_result("Game Over", false)
	elif is_in_group("Enemy"):
		UIManager.show_result("You Win!", false)
	
	queue_free() # 原本的刪除節點
func _draw():
	if not show_state_debug:
		return
	
	if machine == null or machine.state == null:
		return

	# ✅ 拿到所有巢狀 State
	var states: Array = machine.get_actives_state_branch()

	if states.is_empty():
		return

	# ✅ 轉字串
	var names: Array[String] = []
	for s in states:
		names.append(s.name)

	var text := "States: " + " > ".join(names)

	# ✅ 顯示位置（角色頭上）
	var pos := Vector2(0, -120)

	draw_string(
		debug_font,
		pos,
		text,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		16,
		Color.WHITE
	)
	
