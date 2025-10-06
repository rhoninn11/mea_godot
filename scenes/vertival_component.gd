extends Node
class_name VerticalComponent

var mouse_start_point: Vector2
var mouse_capture_ack: bool = false

var axis_delta: Vector2 = Vector2.ZERO
var position: Vector2 = Vector2.ZERO
@export var active_on: Enums.ControlState = Enums.ControlState.NONE
@export var lim: float = 1

var inertia_x: Inertia = null;
var inertia_y: Inertia = null;
func _ready() -> void:
	var cfg_inertia := InertConfig.new();
	self.inertia_x = Inertia.init(cfg_inertia)
	self.inertia_y = Inertia.init(cfg_inertia)

	assert(inertia_x && inertia_y)

func one_minus_one(val: Vector2) -> Vector2:
	return Vector2(clamp(val.x, -lim, lim), clamp(val.y, -lim, lim))

func _process(delta: float) -> void:
	var target: = one_minus_one(position + axis_delta);
	self.inertia_x.simulate(target.x, delta);
	self.inertia_y.simulate(target.y, delta);

	var mouse_capture := ControlContext.control_state == self.active_on
	if mouse_capture:
		var mouse_pos := get_viewport().get_mouse_position()
		if not mouse_capture_ack:
			mouse_start_point = mouse_pos
		mouse_capture_ack = true

		var delta_pos:Vector2 = mouse_start_point-mouse_pos
		axis_delta = delta_pos * 0.01
		
	if not mouse_capture and mouse_capture_ack:
		mouse_capture_ack = false;
		position = fn_val();
		axis_delta = Vector2.ZERO;

func fn_val() -> Vector2:
	return Vector2(
		self.inertia_x.result(),
		self.inertia_y.result()
	)
