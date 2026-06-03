extends Node

var shake_strength: float = 0.0
var original_camera_pos: Vector2

func shake(duration: float = 0.3, strength: float = 8.0):
	shake_strength = strength
	var camera = get_viewport().get_camera_2d()
	if camera:
		if original_camera_pos == Vector2.ZERO:
			original_camera_pos = camera.offset
		
		var tween = create_tween()
		tween.tween_property(self, "shake_strength", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.finished.connect(func(): camera.offset = original_camera_pos)

func _process(_delta):
	if shake_strength > 0:
		var camera = get_viewport().get_camera_2d()
		if camera:
			camera.offset = original_camera_pos + Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
