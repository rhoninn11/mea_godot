extends Area3D
class_name HandTracker

@onready var raycast: RayCast3D = $canvas_pointer
@onready var indicator: MeshInstance3D = $indicator

@export var in_contact: bool = false
@export var is_tracing: bool = false
@export var tracing_pos: Vector3 = Vector3.ZERO

func reset() -> void:
	in_contact = false
	is_tracing = false

func _process(delta: float) -> void:
	indicator.visible = in_contact
	if in_contact:
		is_tracing = raycast.is_colliding()
		if is_tracing:
			calc_interaction()

func calc_interaction() -> void:
	tracing_pos = raycast.get_collision_point()
	indicator.global_transform.origin = tracing_pos 
