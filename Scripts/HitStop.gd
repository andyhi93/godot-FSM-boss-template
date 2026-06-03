extends Node

func stop(frames: int = 6):
	Engine.time_scale = 0.05
	# Convert frames to approximate real time based on 60 FPS
	await get_tree().create_timer(frames * (1.0 / 60.0), true, false, true).timeout
	Engine.time_scale = 1.0
