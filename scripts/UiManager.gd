extends Node
class_name UiManager

var overlay = preload("res://UI/exit_overlay.tscn")

func _ready() -> void:
	
	var main_scene := get_tree().current_scene
	var viewport := main_scene.get_viewport()
	
	var overlay_inst: Control = overlay.instantiate()
	main_scene.add_child(overlay_inst)
	overlay_inst.owner = main_scene
	overlay_inst.size = viewport.size
	
