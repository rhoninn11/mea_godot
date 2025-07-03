extends Node2D
class_name FlatPointer

var holded_node_ref: Node2D = null
var is_holding: bool = false
var last_is_holding: bool = false
@export var main: bool = false


func _recive_pointer(pos: Vector2, hold_action: bool) -> void:
	self.position = pos
	self.is_holding = hold_action

func _body_in(body: Node2D) -> void:
	if body.is_in_group("holdable"):
		if not holded_node_ref:
			holded_node_ref = body
		
func _body_out(body: Node2D) -> void:
	if holded_node_ref == body and not is_holding:
		holded_node_ref = null

func _process(delta: float) -> void:
	if not holded_node_ref:
		return
	
	if is_holding == last_is_holding:
		return
		
	last_is_holding = is_holding
	if is_holding: 	
		holded_node_ref.hold_start(self)
	else: 			
		holded_node_ref.hold_end()
	
