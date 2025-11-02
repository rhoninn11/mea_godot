@tool
extends CSGCombiner3D

@export var profile: PackedVector2Array
@export var turn_val: float = 0
@export var fill: float = 0.5
@export_tool_button("regenerate") var regenerate_btn = regenerate

@export var p_scale_curve: Curve
@export var mesh_resolution: int = 16

func half_i_profile(res: int, spacing: float) -> PackedVector2Array:
	assert(res > 4 && spacing >= 0)

	var top: = Libgeo.Shapes.circle_2D_pos(res, 0.25, true)
	Libgeo.Math.ops2d_move(top, Vector2(0, spacing), false)
	top.reverse()
	
	var bot: = Libgeo.Shapes.circle_2D_pos(res, 0.25, true)
	Libgeo.Math.ops2d_rotate(bot, 0.5, false)
	Libgeo.Math.ops2d_move(bot, Vector2(2,0), false)
	# bot.reverse()
	top.append_array(bot)
	Libgeo.Math.ops2d_move(top, Vector2(0, 1), false)
	top.append(Vector2.ZERO)
	return top

func profile_form_half(half_profile: PackedVector2Array) -> PackedVector2Array:
	var left_copy := Libgeo.Math.ops2d_scale(half_profile, Vector2(1, 1), true)
	var right_copy := Libgeo.Math.ops2d_scale(left_copy, Vector2(-1, 1), true)
	right_copy = right_copy.slice(1, len(right_copy)-1)	
	right_copy.reverse()
	left_copy.append_array(right_copy)
	return left_copy;

func regenerate():
	for child in get_children():
		print("removing ", child)
		remove_child(child)
		child.free()
		
	csg_geometry()
	print("geometry spawned")


@export var p_diameter: float = 7;
@export var p_y_spacing: float = 1;
@export var p_y_flip: bool = false;
@export var p_along_flip: bool = false;	

var m_xforms: Array[Transform3D]

func csg_geometry():
	assert(p_scale_curve)
	
	var resolution = mesh_resolution;
	var _half_profile = half_i_profile(resolution, p_y_spacing)
	if p_y_flip:
		var scale_flip = Vector2(1, -1);
		_half_profile = Libgeo.Math.ops2d_scale(_half_profile, scale_flip)
	
	var _profile: = profile_form_half(_half_profile)
	
	var ts: = Libgeo.Shapes.circle_4d(64, 0.75, false)
	Libgeo.Math.scale_along_xforms_o(ts, p_diameter)
	
	var sapmles: = Libgeo.Tools.sample_curve(p_scale_curve, len(ts))
	if p_along_flip:
		sapmles.reverse()
	ts = Libgeo.Math.scale_along_xforms(ts, sapmles)
	
	var tranform_polygon = CSGAlongTransform.new()
	self.add_child(tranform_polygon)
	tranform_polygon.owner = get_tree().edited_scene_root
	
	tranform_polygon.name = "tranformed_profile"
	tranform_polygon.polygon = _profile
	tranform_polygon.transform_data = Libgeo.Itop.pkd_xform(ts)

	var first_t: = ts[0];
	spawn_cap(_half_profile, first_t, "cap_0")

	var last_t: = ts[len(ts) - 1];
	spawn_cap(_half_profile, last_t, "cap_1")

func spawn_cap(shape: PackedVector2Array, xform: Transform3D, _name: String) -> void:
	var cap_0 = CSGPolygon3D.new()
	self.add_child(cap_0)
	cap_0.owner = get_tree().edited_scene_root

	cap_0.name = _name
	cap_0.mode = CSGPolygon3D.MODE_SPIN;
	cap_0.spin_degrees = 360
	cap_0.polygon = shape 
	cap_0.transform = xform
	cap_0.spin_sides = 16;

func as_path(ts: Array[Transform3D]) -> Path3D:
	var num = len(ts)
	var path_3d_node = Path3D.new()
	self.add_child(path_3d_node)
	path_3d_node.owner = get_tree().edited_scene_root
	

	var curve_3d = Curve3D.new()
	for i in range(num):
		var _in: Vector3 = Vector3.ZERO
		var _out: Vector3 = Vector3.ZERO
		curve_3d.add_point(ts[i].origin, _in, _out)
	
	
	path_3d_node.name = "half_circle"
	path_3d_node.curve = curve_3d
	return path_3d_node
