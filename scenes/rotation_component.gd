class_name RotationComponent
extends Node

@export var active_on: Enums.ControlState = Enums.ControlState.NONE
@export var speed: float = 0.07
var turn_keys: float = 0
var turn_mouse: float = 0

var capture_ack: bool = false
var mouse_start_point: Vector2

var inertia: Inertia;

func _ready() -> void:
	var icfg = InertParams.new()
	inertia = Inertia.init(icfg)
	assert(self.inertia)

func _process(delta: float) -> void:
	var target := turn_keys + turn_mouse;
	self.inertia.simulate(target, delta)
	
	var mv_vec = Input.get_vector("turn_right", "turn_left", "noop", "noop")
	if mv_vec != Vector2.ZERO:
		turn_keys += mv_vec.x * speed

	var to_capture = ControlContext.control_state == self.active_on
	
	if to_capture:
		var mouse_pos = get_viewport().get_mouse_position()
		if not capture_ack:
			mouse_start_point = mouse_pos
		capture_ack = true
		var delta_pos:Vector2 = mouse_start_point-mouse_pos
		turn_mouse = delta_pos.x * 0.01
	
	if not to_capture and capture_ack:
		capture_ack = false
		turn_keys += turn_mouse
		turn_mouse = 0


func fn_turn() -> float:
	return self.inertia.result()
