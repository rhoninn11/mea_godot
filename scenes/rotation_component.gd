class_name RotationComponent
extends Node

@export var speed: float = 0.07
var turn_keys: float = 0
var turn_mouse: float = 0

var mouse_turning_ack: bool = false
var mouse_start_point: Vector2

func _process(delta: float) -> void:
	var mv_vec = Input.get_vector("turn_right", "turn_left", "noop", "noop")
	if mv_vec != Vector2.ZERO:
		turn_keys += mv_vec.x * speed

	var mouse_capture = Input.is_action_pressed("mouse_capture")
	if mouse_capture:
		var mouse_pos = get_viewport().get_mouse_position()
		if not mouse_turning_ack:
			mouse_start_point = mouse_pos
		mouse_turning_ack = true
		var delta_pos:Vector2 = mouse_start_point-mouse_pos
		turn_mouse = delta_pos.x * 0.01
	
	if not mouse_capture and mouse_turning_ack:
		mouse_turning_ack = false
		turn_keys += turn_mouse
		turn_mouse = 0


func fn_turn() -> float:
	return turn_keys + turn_mouse
