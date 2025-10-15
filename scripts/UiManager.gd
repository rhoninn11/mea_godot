extends Node
class_name UiManager

var overlay = preload("res://UI/exit_overlay.tscn")
var overlay_0 = preload("res://UI/debug_overlay.tscn")

	
static var debug_map: = {};
static func print(key: String, value: String) -> void:
	debug_map[key] = value;

func _ready() -> void:
	
	var main_scene := get_tree().current_scene
	var viewport := main_scene.get_viewport()
	
	var overlay_inst: Control = overlay.instantiate()
	main_scene.add_child(overlay_inst)
	overlay_inst.owner = main_scene
	overlay_inst.size = viewport.size

	var overlay_inst_0: Control = overlay_0.instantiate()
	main_scene.add_child(overlay_inst_0)
	overlay_inst_0.owner = main_scene
	overlay_inst_0.size = viewport.size
