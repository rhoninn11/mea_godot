@tool
extends Camera3D

@export_tool_button("test_transform") var xform_btn = xform_test

@export var target: Node3D
@export var turn_rate: float = 1

var tpos_last: Vector3
var tpos: Vector3
var good: bool = false
var under_turn:bool = false
var start_point:Vector2
@export var actual_turn: float = 0
var mouse_turn: float = 0

var view_port_ref: Viewport
func _ready() -> void:
	view_port_ref = get_viewport()

func adjust_position(pos: Vector3) -> void:
	var t = Transform3D()
	t = t.rotated(Vector3.UP, actual_turn + mouse_turn)
	var camera_offset = t * Vector3(0, 2, -3)
	transform.origin = pos + camera_offset
	transform = transform.looking_at(target.position)

func turn_motion(delta: float) -> void:
	var left = Input.is_action_pressed("turn_left")
	var right = Input.is_action_pressed("turn_right")
	
	if left:
		actual_turn	+= turn_rate*delta
		print("turn left")
	if right:
		actual_turn	+= -turn_rate*delta
		print("turn right")
		
	
	var ut = Input.is_action_pressed("under_turn")
	if ut:
		print("ut")
		if not under_turn:
			start_point = get_viewport().get_mouse_position()
		under_turn = true
		var pos_delta:Vector2 = start_point-view_port_ref.get_mouse_position()
		mouse_turn = pos_delta.x * 0.01
	
	
	
	if not ut:
		under_turn = false
		actual_turn += mouse_turn
		mouse_turn = 0

func track_target() -> void:
	if target == null:
		return

	if not good:
		self.tpos_last = target.position
		good = true
	
	tpos = target.position
	if tpos_last != tpos:
		#print("My target change tpos to: ", tpos)
		pass

	tpos_last = tpos

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		pass
	else:
		turn_motion(delta)
		track_target()
		adjust_position(self.tpos)


func xform_test() -> void:

	var tangent = Vector3(0, 0, 1)

	var z = -tangent
	var y = Vector3(0, 1, 0)
	var x = y.cross(z)

	var o = self.transform.origin
	var new_t = Transform3D(x, y, z, o)
	self.transform = new_t
