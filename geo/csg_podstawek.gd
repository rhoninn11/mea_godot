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
		
	var bar_len: = 45.0
	var sub1: = geometry(bar_len, 1.0/16, 0.1)
	var sub2: = geometry(bar_len, -1.0/8, -0.1)
	var canv: = spawn_canvas()

	sub1.reparent(canv, false)
	sub2.reparent(canv, false)
	var _box: = spawn_box(canv)
	_box.operation = CSGShape3D.OPERATION_INTERSECTION
	_box.size = Vector3(bar_len/2, 10, bar_len/2)

	var thick := 7

	var pos_arr := Libgeo.Memory.data_2d(2, Vector2.ZERO)
	pos_arr[1] = Vector2.UP*0.5*thick;
	pos_arr[0] = -Vector2.UP*0.5*thick;	
	var tang_arr := Libgeo.Memory.data_2d(2, Vector2.UP)
	var xform_spawn_data := Libgeo.Memory.shuffle(pos_arr, tang_arr)

	var ts := Libgeo.Itop.xforms_from_2d(xform_spawn_data)
	spawn_path(self, ts)
	var profile := Libgeo.Shapes.Profiles.right_triangle(Vector2(30,15))
	var along := spawn_along(canv, ts, profile)
	along.operation = CSGShape3D.OPERATION_INTERSECTION

@export var bar_count: int = 5;
func geometry(line_len: float, rot_rate: float, shift: float) -> CSGCombiner3D:
	assert(bar_count >= 1)	
	print("generating_geometry")

	var num: int = 12
	var line := Libgeo.Shapes.line_1d(num, line_len)
	var pos_2d := Libgeo.Shapes.empty_2d(num)
	var tangent_2d := Libgeo.Shapes.empty_2d(num)
	for i in range(len(line)):
		pos_2d[i] = Vector2(line[i], 0)
		tangent_2d[i] = Vector2(1, 0)
	Libgeo.Math.ops2d_move(pos_2d, Vector2(-line_len/2, 0))

	var rate: float = rot_rate
	var rate_rad: = rate*TAU
	var dir_vec: = Vector2(-sin(rate_rad), cos(rate_rad))
	print("dir vec: ", dir_vec, " rate ", rate)
	var shift_vec: = Vector3(0, shift, 0)
	Libgeo.Math.ops2d_rotate(pos_2d, rate)
	Libgeo.Math.ops2d_rotate(tangent_2d, rate)
	
	var canv := spawn_canvas()
	var profile := Libgeo.Shapes.Profiles.square();
	Libgeo.Math.ops2d_scale(profile, Vector2(1, 0.5))

	
	var posnorm_data: PackedVector4Array;
	var xforms: Array[Transform3D];
	var spacing: float = 2.24;
	Libgeo.Math.ops2d_move(pos_2d, -dir_vec*spacing*(bar_count-1)*0.5)

	for i in range(bar_count):
		posnorm_data = Libgeo.Memory.shuffle(pos_2d, tangent_2d)
		xforms = Libgeo.Itop.xforms_from_2d(posnorm_data)
		Libgeo.Math.ops3d_move(xforms, shift_vec) 
		spawn_along(canv, xforms, profile)
		Libgeo.Math.ops2d_move(pos_2d, dir_vec*spacing)
	
	return canv
	
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