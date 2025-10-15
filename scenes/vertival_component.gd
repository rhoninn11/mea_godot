extends Node
class_name VerticalComponent

var root_pos: Vector2
var active_ack: bool = false

var m_pos: Vector2 = Vector2.ZERO
var m_delta_pos: Vector2 = Vector2.ZERO
@export var active_on: Enums.ControlState = Enums.ControlState.NONE;
@export var lim_2d: Vector2 = Vector2(1, 1);

func apply_lim(val: Vector2, lim: Vector2) -> Vector2:
	return Vector2(clamp(val.x, -lim.x, lim.x), clamp(val.y, -lim.y, lim.y))

func simulate(_delta: float, active: bool) -> void:
	if active:
		var active_pos := get_viewport().get_mouse_position()*0.01; 
		#scale down from screan resolution
		if not active_ack:
			active_ack = true
			root_pos = active_pos

		m_delta_pos = root_pos - active_pos
		
	if not active and active_ack:
		m_pos = fn_val();
		m_delta_pos = Vector2.ZERO;
		active_ack = false;

func fn_val() -> Vector2:
	return apply_lim(m_pos + m_delta_pos, lim_2d);
