@tool
extends Node3D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
    
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return


@export_tool_button("regenerate") var regenerate_btn = regenerate
func regenerate():
	for child in get_children():
		print("removing ", child.name)
		remove_child(child)
		child.free()
		
	geometry()

@export var seg_count: int = 5;
func geometry() -> void:
	assert(seg_count >= 1)	

	var SQ2: = sqrt(2)
	var num: int = 12
	var line_len: float = 18;
	var line := Libgeo.Shapes.line_1d(num, line_len)
	var pos_2d := Libgeo.Shapes.empty_2d(num)
	var tangent_2d := Libgeo.Shapes.empty_2d(num)
	for i in range(len(line)):
		pos_2d[i] = Vector2(line[i], 0)
		tangent_2d[i] = Vector2(1, 0)
		print(pos_2d[i])
	Libgeo.Math.ops2d_move(pos_2d, Vector2(-line_len/2, 0))

	var rate: float = 0;
	Libgeo.Math.ops2d_rotate(pos_2d, rate)
	Libgeo.Math.ops2d_rotate(tangent_2d, rate)
	
	var canv := spawn_canvas()
	var profile := Libgeo.Shapes.Profiles.square();
	Libgeo.Math.ops2d_scale(profile, Vector2(1, 0.5))

	
	var posnorm_data: PackedVector4Array;
	var xforms: Array[Transform3D];
	var spacing: float = 2;

	for i in range(5):
		posnorm_data = Libgeo.Memory.shuffle(pos_2d, tangent_2d)
		xforms = Libgeo.Shapes.transfer_3d_from_data_2d(posnorm_data)
		spawn_along(canv, xforms, profile)
		Libgeo.Math.ops2d_move(pos_2d, Vector2(0, spacing*SQ2))
	
func spawn_canvas() -> CSGCombiner3D:
	var combiner = CSGCombiner3D.new()
	self.add_child(combiner)
	combiner.owner = get_tree().edited_scene_root
	combiner.name = "csg_combiner"
	return combiner

func spawn_box(to: Node3D) -> CSGBox3D:
	var box = CSGBox3D.new()
	to.add_child(box)
	box.owner = get_tree().edited_scene_root
	box.name = "csg_control_box"
	return box

func spawn_along(to: Node3D, xfomrs: Array[Transform3D], profile: PackedVector2Array) -> CSGAlongTransform:
	var tranform_polygon = CSGAlongTransform.new()
	to.add_child(tranform_polygon)
	tranform_polygon.owner = get_tree().edited_scene_root
	
	tranform_polygon.name = "tranformed_profile"
	tranform_polygon.polygon = profile
	tranform_polygon.transform_data = Libgeo.Itop.pkd_xform(xfomrs)
	return tranform_polygon

func spawn_path(to: Node3D, xforms: Array[Transform3D]) -> Path3D:
	var curve := Curve3D.new();
	for xform in xforms:
		curve.add_point(xform.origin)

	var debug_path = Path3D.new()
	to.add_child(debug_path)
	debug_path.owner = get_tree().edited_scene_root
	debug_path.name = "debug_path"
	debug_path.curve = curve

	return debug_path