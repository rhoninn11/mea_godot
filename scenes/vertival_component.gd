extends Node
class_name VerticalComponent

var mouse_start_point: Vector2
var mouse_capture_ack: bool = false

var axis_delta: Vector2 = Vector2.ZERO
var position: Vector2 = Vector2.ZERO
@export var active_on: Enums.ControlState = Enums.ControlState.NONE
@export var lim: float = 1
func one_minus_one(val: Vector2) -> Vector2:
	return Vector2(clamp(val.x, -lim, lim), clamp(val.y, -lim, lim))

func _process(delta: float) -> void:
	var mouse_capture := ControlContext.control_state == self.active_on
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
