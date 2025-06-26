@tool
extends Node3D

@export var scene: PackedScene = null
@onready var viewport: SubViewport = $SubViewport
@onready var painting_ray: RayCast3D = $painting/RayCast3D
@onready var painting: MeshInstance3D = $painting
@onready var floor_ray: RayCast3D = $floor/RayCast3D		

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
