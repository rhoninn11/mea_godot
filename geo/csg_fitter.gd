@tool
extends Node3D

func spawn_canvas(to: Node3D) -> CSGCombiner3D:
	var combiner = CSGCombiner3D.new()
	to.add_child(combiner)
	combiner.owner = get_tree().edited_scene_root
	combiner.name = "csg_combiner"
	return combiner

func spawn_boc(to: Node3D, size: Vector3) -> CSGBox3D:
	var box = CSGBox3D.new()
	to.add_child(box)
	box.owner = get_tree().edited_scene_root
	box.name = "csg_box"
	box.size = size 
	return box

@export_tool_button("regenerate") var regenerate_btn = regenerate
func regenerate():
	for child in get_children():
		print("removing ", child.name)
		remove_child(child)
		child.free()

	var fitter_canvas := spawn_canvas(self)
	var holes_canvas := spawn_canvas(self)
	var vesle_size := Vector3(120, 10, 8)
	var hole_base := Vector3(9.8,100, 1.8)
	spawn_boc(fitter_canvas, vesle_size)
	
	var base_loc := Vector3(50, 0, 0)
	var space := 4
	var delta := 0.05
	for i in range(8):
		var hole_size := hole_base + Vector3(delta*i, 0, 0)
		var box := spawn_boc(holes_canvas, hole_size)
		box.translate(base_loc)
		base_loc.x -= hole_size.x + space
	
	holes_canvas.operation = CSGShape3D.OPERATION_SUBTRACTION
	holes_canvas.reparent(fitter_canvas)
	
