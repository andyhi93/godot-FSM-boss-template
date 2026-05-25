extends State

@export var windup_time: float = 0.5
@export var stun_time: float = 1.0 
@export var tracking_speed: float = 150.0 
@export var attack_range: float = 120.0   

var has_slashed: bool = false

func enter():
	super.enter()
	has_slashed = false
	core.velocity = Vector2.ZERO 
	
	if core.is_phase2(): 
		windup_time = 0.25
		stun_time = 0.5

func fixed_do(_delta: float):
	
	if time < windup_time:
		if is_instance_valid(core.player):
			var dist = core.global_position.distance_to(core.player.global_position)
			
			if dist > attack_range:
				var dir = core.global_position.direction_to(core.player.global_position)
				core.velocity = dir * tracking_speed
			else:
				core.velocity = Vector2.ZERO
		else:
			core.velocity = Vector2.ZERO
			
	elif not has_slashed:
		core.execute_melee_attack()
		has_slashed = true
		core.velocity = Vector2.ZERO 
		
	if time > stun_time:
		core.start_cd("melee")
		is_complete = true

func exit():
	core.velocity = Vector2.ZERO
