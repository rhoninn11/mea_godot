@tool
extends Camera3D

@onready var rot: RotationComponent = $rotation_component
@export var target: Node3D
@export var turn_rate: float = 1
@export var camera_distance: float = 1

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
	var val = rot.fn_turn()

func adjust_position(pos: Vector3) -> void:
	var t = Transform3D()
	t = t.rotated(Vector3.UP, rot.fn_turn())
	var camera_offset = t * Vector3(0, 2, -3) * camera_distance
	transform.origin = pos + camera_offset
	transform = transform.looking_at(target.position)


func track_target() -> void:
	if target == null:
		return

	if not good:
		self.tpos_last = target.position
		good = true
	
	tpos = target.position
#	meaby some actions in a futere
#   for example some arm sprint

	tpos_last = tpos

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
		

	track_target()
	adjust_position(self.tpos)
