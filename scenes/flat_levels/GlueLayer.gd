@tool
extends Node2D
class_name GlueLayer

@export_tool_button("spwan", "Callable") var btn_spawn = spawn

@export var width: int = 512
@export var height: int = 512
@export var area_node: Area2D
@export var main: bool = false

var s_pointer = preload("res://scenes/flat_elements/flat_pointer.tscn")
var pointer_ref: FlatPointer

signal pass_data(v: Vector2, b: bool)

func _ready() -> void:
	spawn_area()
	assert(area_node)
	area_node.body_exited.connect(self._okej)
	
	pointer_ref = s_pointer.instantiate() as FlatPointer
	assert(pointer_ref)
	add_child(pointer_ref)
	pointer_ref.name = "pointer"
	pointer_ref.owner = self
	
	pass_data.connect(pointer_ref._recive_pointer)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if main:
		pointer_ref._recive_pointer(
			get_global_mouse_position(),
			Input.is_action_pressed("pointer")
		)
	

func _exit_tree() -> void:
	print("tree exited")

func spawn() -> void:
	if area_node != null:
		print(area_node.body_exited)
		remove_child(area_node)
	spawn_area()
	print("spawn")

func spawn_area() -> void:
	area_node = Area2D.new()
	self.add_child(area_node)
	area_node.name = "stay_in"
	area_node.owner = self
	
	var rect = RectangleShape2D.new()
	var zone_shape = CollisionShape2D.new()
	area_node.add_child(zone_shape)
	zone_shape.shape = rect
	zone_shape.name = "zone_shape"
	zone_shape.owner = self
	
	zone_shape.position = Vector2(int(width/2), int(height/2))
	rect.size = Vector2(int(width)*0.75, int(height)*0.75)
	
		
func _okej(area: Node2D) -> void:
	print("okej")
