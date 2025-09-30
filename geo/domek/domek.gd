@tool
extends Node

var in_edit: bool = false;
var last_outter_size: Vector3;
@onready var outer: CSGBox3D = $"CSGBox3D_outer";
@onready var inner = $"CSGBox3D2";

@export var update_interval: float = 0.1
@export var wall_thickness: float = 0.1

func edit_activity() -> void:
	assert(outer && inner);
	if last_outter_size == outer.size: return;

	last_outter_size = outer.size;
	inner.size = last_outter_size - (Vector3.ONE * wall_thickness * 2);
	inner.position = outer.position


func _ready() -> void:
	in_edit = Engine.is_editor_hint();
	if in_edit: return;		


func _process(delta: float) -> void:
	if not in_edit: return;
	edit_activity()
	
