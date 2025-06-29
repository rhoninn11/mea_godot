@tool
extends Node3D

@export var scene: PackedScene = null

@onready var viewport: SubViewport = $SubViewport
@onready var painting: MeshInstance3D = $calc_origin/painting

@onready var painting_ray: RayCast3D = $calc_origin/raycast
@onready var floor_ray: RayCast3D = $floor/raycast

@onready var calc_origin: Node3D = $calc_origin

func _ready() -> void:
	if scene:
		var flat_scene = scene.instantiate()
		viewport.add_child(flat_scene)
		flat_scene.name = "live_painting"
		flat_scene.owner = viewport

		var display_mat = StandardMaterial3D.new()
		display_mat.albedo_texture = flat_scene.get_viewport().get_texture()
		painting.set_surface_override_material(0, display_mat)
		
func _process(delta: float) -> void:
	if painting_ray.is_colliding():
		var text = "wall colision, "
		if floor_ray.is_colliding():
			text = text + "floor colision"
		print(text)

	pass_interaction()

func pass_interaction() -> void:
	if observing == null:
		return

	if not observing.is_tracing:
		return

	var contact := observing.tracing_pos - calc_origin.global_transform.origin
	var x_axis := calc_origin.global_transform.basis[0]
	var y_axis := calc_origin.global_transform.basis[1]
	var s := painting.scale
	var coords := Vector2(contact.dot(x_axis/s.x), contact.dot(y_axis/s.y))
	print("coords on painting: ", coords)
	


var observing: HandTracker = null
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("canvas"):
		var hand_tracker: HandTracker = area as HandTracker
		if hand_tracker:
			observing = hand_tracker 
			observing.in_contact = true

func _on_area_3d_area_exited(area: Area3D) -> void:
	if observing == area:
		observing.in_contact = false
		observing = null
