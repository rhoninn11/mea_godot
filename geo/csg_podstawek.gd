@tool
extends Node3D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return


@export_tool_button("regenerate") var regenerate_btn = regenerate
@export var bar_len: float = 60
@export var bar_size: float = 3
func regenerate():
	for child in get_children():
		print("removing ", child.name)
		remove_child(child)
		child.free()

	var bar_canv := spawn_canvas(self)

	var bar_data: BarData = BarData.new()
	bar_data.bar_count = bar_count
	bar_data.bar_len = bar_len
	bar_data.spacing = bar_size

	var bar_profile := Libgeo.Shapes.Profiles.square();
	Libgeo.Math.ops2d_scale(bar_profile, Vector2(1, 0.5)*4)
	bar_profile = Libgeo.Shapes.Profiles.convex_rounded(bar_profile, 0.5, 6)

	var slide: float = 0.0

	bar_data.bar_profile = Libgeo.Memory.copy(bar_profile)
	Libgeo.Math.ops2d_move(bar_data.bar_profile, Vector2(0,slide*0.5))
	spawn_bars(bar_canv, bar_data, 1.0/16)
	bar_data.bar_profile = Libgeo.Memory.copy(bar_profile)
	Libgeo.Math.ops2d_move(bar_data.bar_profile, Vector2(0,-slide*0.5))
	spawn_bars(bar_canv, bar_data, -1.0/8)

	var thick := 3
	var tri_size = Vector2(180,90)
	var corner_r: float = 7
	var triangle := Libgeo.Shapes.Profiles.right_triangle(tri_size)
	var profile = Libgeo.Shapes.Profiles.convex_rounded(triangle, corner_r)

	var merge_canv := spawn_canvas(self)
	bar_canv.reparent(merge_canv)
	spawn_form(merge_canv, profile, thick)

	var final_canv := spawn_canvas(self)
	merge_canv.reparent(final_canv)
	var rim_rofile := Libgeo.Shapes.Profiles.square(10)
	Libgeo.Math.ops2d_scale(rim_rofile, Vector2(1, 1))
	rim_rofile = Libgeo.Shapes.Profiles.convex_rounded(rim_rofile, 0.5, 5)
	spawn_rim(final_canv, tri_size, corner_r, rim_rofile)


@export var direction: Libgeo.Shapes.Axis = Libgeo.Shapes.Axis.AX_X
func spawn_form(to: Node3D, profile: PackedVector2Array, thickness: float) -> void:
	var ts := Libgeo.Shapes.line_xform(direction, thickness)
	var along := spawn_along(to, ts, profile)
	along.operation = CSGShape3D.OPERATION_INTERSECTION
	# debug 
	spawn_path(to, ts)

func spawn_rim(to: Node3D, tri_size: Vector2, corner_r: float, rim_profile: PackedVector2Array) -> void:
	var triangle := Libgeo.Shapes.Profiles.right_triangle(tri_size)
	var rim_pos = Libgeo.Shapes.Profiles.convex_rounded(triangle, corner_r)
	var rim_tang = Libgeo.Shapes.Profiles.convex_rounded_tang(triangle)

	var rim_data := Libgeo.Memory.shuffle(rim_pos, rim_tang)
	var rim_xforms := Libgeo.Itop.xforms_from_2d(rim_data)

	rim_xforms.append(rim_xforms[0])
	spawn_along(to, rim_xforms, rim_profile)
	
func spawn_cap(to: Node3D, shape: PackedVector2Array) -> void:
	var cap_0 = CSGPolygon3D.new()
	to.add_child(cap_0)
	cap_0.owner = get_tree().edited_scene_root

	cap_0.name = "Rotation"
	cap_0.mode = CSGPolygon3D.MODE_SPIN;
	cap_0.spin_degrees = 360
	cap_0.polygon = shape 
	cap_0.spin_sides = 16;	

class BarData extends Resource:
	@export var bar_count: int
	@export var bar_len: float
	@export var bar_profile: PackedVector2Array
	@export var spacing: float

@export var bar_count: int = 5;
func spawn_bars(to: Node3D, bar_data: BarData, rot_rate: float,) -> void:
	assert(bar_count >= 1)	
	print("generating_geometry")

	var num: int = 12
	var line := Libgeo.Shapes.line_1d(num, bar_data.bar_len)
	var pos_2d := Libgeo.Shapes.empty_2d(num)
	var tangent_2d := Libgeo.Shapes.empty_2d(num)
	for i in range(len(line)):
		pos_2d[i] = Vector2(line[i], 0)
		tangent_2d[i] = Vector2(1, 0)
	Libgeo.Math.ops2d_move(pos_2d, Vector2(-bar_data.bar_len/2, 0))

	var rate: float = rot_rate
	var rate_rad: = rate*TAU
	var dir_vec: = Vector2(-sin(rate_rad), cos(rate_rad))
	print("dir vec: ", dir_vec, " rate ", rate)
	# var shift_vec: = Vector3(0, shift, 0)
	Libgeo.Math.ops2d_rotate(pos_2d, rate)
	Libgeo.Math.ops2d_rotate(tangent_2d, rate)
	
	
	var posnorm_data: PackedVector4Array;
	var xforms: Array[Transform3D];
	var total_len := (bar_data.bar_count-1)*bar_data.spacing
	var delta_vec := dir_vec*bar_data.spacing
	Libgeo.Math.ops2d_move(pos_2d, -dir_vec*0.5*total_len)

	for i in range(bar_count):
		posnorm_data = Libgeo.Memory.shuffle(pos_2d, tangent_2d)
		xforms = Libgeo.Itop.xforms_from_2d(posnorm_data)
		# Libgeo.Math.ops3d_move(xforms, shift_vec) 
		spawn_along(to, xforms, bar_data.bar_profile)
		Libgeo.Math.ops2d_move(pos_2d, delta_vec)
	
	
func spawn_canvas(to: Node3D) -> CSGCombiner3D:
	var combiner = CSGCombiner3D.new()
	to.add_child(combiner)
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
