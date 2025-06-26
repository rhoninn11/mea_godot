@tool
extends Node2D
class_name GlueLayer

@export_tool_button("spwan", "Callable") var btn_spawn = spawn

@export var width: int = 512
@export var height: int = 512
@export var area_node: Area2D

func _ready() -> void:
	if area_node:
		area_node.body_exited.connect(self._okej)
		print("idono")
	pass
	
func custom() -> void:
	print("Custom glue")

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


func _on_stay_in_body_exited(body: Node2D) -> void:
	print("signal signaling")
	pass # Replace with function body.
