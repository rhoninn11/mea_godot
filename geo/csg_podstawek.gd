@tool
extends Node3D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
    
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return


@export_tool_button("regenerate") var regenerate_btn = regenerate
@export var p_switch: int = 0
func regenerate():
	for child in get_children():
		print("removing ", child.name)
		remove_child(child)
		child.free()
		
	var bar_canv := spawn_canvas()

	var bar_len: = 45.0
	geometry(bar_canv, bar_len, 1.0/16, 0.1)
	geometry(bar_canv, bar_len, -1.0/8, -0.1)

	var thick := 3
	var profile := Libgeo.Shapes.Profiles.right_triangle(Vector2(30,15))
	if p_switch == 1:
		profile = Libgeo.Shapes.Profiles.right_triangle(Vector2(30,15), true, true)
	if p_switch == 2:
		profile = Libgeo.Shapes.Profiles.right_triangle_rounded(Vector2(25.95,15), 4.0)
	if p_switch == 3:
		profile = Libgeo.Shapes.Profiles.half_i(16, 1.0)
		Libgeo.Math.ops2d_scale(profile, Vector2.ONE*7)

	var merge_canv := spawn_canvas()
	bar_canv.reparent(merge_canv)
	spawn_form(merge_canv, profile, thick)
	# spawn_cap(canv, profile)


@export var direction: Libgeo.Shapes.Axis = Libgeo.Shapes.Axis.AX_X
func spawn_form(to: Node3D, profile: PackedVector2Array, thickness: float) -> void:
	var ts := Libgeo.Shapes.line_xform(direction, thickness)
	var along := spawn_along(to, ts, profile)
	along.operation = CSGShape3D.OPERATION_INTERSECTION
	# debug 
	spawn_path(to, ts)

func spawn_rim(to: Node3D, profile: PackedVector2Array) -> void:
	var rim_shape := Libgeo.Shapes.Profiles.square(3)
	# TODO: not finished
	
func spawn_cap(to: Node3D, shape: PackedVector2Array) -> void:
	var cap_0 = CSGPolygon3D.new()
	to.add_child(cap_0)
	cap_0.owner = get_tree().edited_scene_root

	cap_0.name = "Rotation"
	cap_0.mode = CSGPolygon3D.MODE_SPIN;
	cap_0.spin_degrees = 360
	cap_0.polygon = shape 
	cap_0.spin_sides = 16;	

@export var bar_count: int = 5;
func geometry(to: Node3D, line_len: float, rot_rate: float, shift: float) -> void:
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
		spawn_along(to, xforms, profile)
		Libgeo.Math.ops2d_move(pos_2d, dir_vec*spacing)
	
	
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
