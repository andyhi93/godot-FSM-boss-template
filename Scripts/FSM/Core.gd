# res://Scripts/FSM/Core.gd
extends CharacterBody2D
class_name Core

@export var max_hp: int = 100
var current_hp: int
var is_dead: bool = false

@onready var rb: CharacterBody2D = self 
@onready var animator: AnimationPlayer = $AnimationPlayer 

var machine: StateMachine
var state: State:
	get: return machine.state if machine else null

func _ready():
	current_hp = max_hp
	set_up_instances()
	init_behavior() # 留給子類別 (Boss/Player) 實作

func set_up_instances():
	machine = StateMachine.new()
	# Godot 遞迴尋找所有繼承自 State 的子節點 (對應 GetComponentsInChildren)
	var all_child_states = find_children("*", "State", true, false)
	for s in all_child_states:
		s.set_core(self)

func set_state(new_state: State, force_reset: bool = false):
	machine.set_state(new_state, force_reset)

func _process(delta):
	if is_dead: return
	
	# 對應你的: if (state.isComplete) SelectState();
	if state and state.is_complete:
		select_state()
		
	if machine and machine.state:
		machine.state.do_branch(delta)

func _physics_process(delta):
	if is_dead: return
	if machine and machine.state:
		machine.state.fixed_do_branch(delta)
	
	move_and_slide() # 統一在這裡執行物理移動

# --- 虛擬函式 ---
func init_behavior(): pass
func select_state(): pass

# --- 戰鬥基礎 ---
func take_damage(damage: int):
	if is_dead: return
	current_hp = clampi(current_hp - damage, 0, max_hp)
	if current_hp <= 0:
		die()

func die():
	is_dead = true
