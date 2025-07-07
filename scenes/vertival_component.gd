extends Node
class_name VerticalComponent

var mouse_start_point: Vector2
var mouse_capture_ack: bool = false

var axis_delta: Vector2 = Vector2.ZERO
var position: Vector2 = Vector2.ZERO

func one_minus_one(val: Vector2) -> Vector2:
	return Vector2(clamp(val.x, -1,1), clamp(val.y, -1, 1))

func _process(delta: float) -> void:
	var mouse_capture := Input.is_action_pressed("mouse_capture")
	if mouse_capture:
		var mouse_pos := get_viewport().get_mouse_position()
		if not mouse_capture_ack:
			mouse_start_point = mouse_pos
		mouse_capture_ack = true

		var delta_pos:Vector2 = mouse_start_point-mouse_pos
		axis_delta = delta_pos * 0.01
		
	if not mouse_capture and mouse_capture_ack:
		mouse_capture_ack = false
		position = one_minus_one(position + axis_delta)
		axis_delta = Vector2.ZERO

func fn_val() -> Vector2:
	return one_minus_one(position + axis_delta)
