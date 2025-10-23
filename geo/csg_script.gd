@tool
extends CSGCombiner3D

@export var profile: PackedVector2Array
@export var turn_val: float = 0
@export var fill: float = 0.5
@export_tool_button("regenerate") var regenerate_btn = regenerate

@export var p_scale_curve: Curve
@export var mesh_resolution: int = 8

var shift: float = 1.5;
	
func translate_2d(arr2D: PackedVector2Array, delta: Vector2) -> PackedVector2Array:
	var scratchpad: PackedVector2Array
	scratchpad.resize(arr2D.size())
	for i in range(arr2D.size()):
		var moved = arr2D[i] + delta
		scratchpad[i] = moved
	return scratchpad

func rotate_2d(arr2D: PackedVector2Array, turn: float) -> PackedVector2Array:
	var rad_angle = TAU * turn
	var scratchpad: PackedVector2Array
	scratchpad.resize(arr2D.size())
	for i in range(arr2D.size()):
		scratchpad[i] = arr2D[i].rotated(rad_angle)
	return scratchpad
	
func scale_2d(arr2D: PackedVector2Array, scale: Vector2) -> PackedVector2Array:
	var scratchpad: PackedVector2Array
	scratchpad.resize(arr2D.size())
	for i in range(arr2D.size()):
		scratchpad[i] = arr2D[i]*scale
		
	return scratchpad

# to ma taki kształ spawu chyba, ale nie wiem jeszcze jak to dobrze nazwać
func bump(res: int) -> PackedVector2Array:
	assert(res > 8)

	var half = Libgeo.Shapes.circle_2D_pos(res*2, 0.5, true)
	var quater = Libgeo.Shapes.circle_2D_pos(res, 0.25, true)
	quater.reverse()
		
	var start = rotate_2d(quater, 0.5)
	var end = rotate_2d(quater, 0.75)
	
	start = translate_2d(start, Vector2(2, -0.5))
	start.get(0)
	
	end = translate_2d(end, Vector2(-2, -0.5))
	var middle = translate_2d(half, Vector2(0, 0.5))

	start.append_array(middle)
	start.append_array(end)

	return translate_2d(start, Vector2(0, shift))

func half_bump(resolution: int) -> PackedVector2Array:
	if resolution < 4:
		push_error("+++ bad resolution")
	
	var quater_a: = Libgeo.Shapes.circle_2D_pos(resolution, 0.25, true)
	var quater_b: = Libgeo.Shapes.circle_2D_pos(resolution, 0.25, true)
	quater_b.reverse()

	quater_a = translate_2d(quater_a, Vector2(0, 0.5 + shift))
	quater_b = rotate_2d(quater_b, 0.5)
	quater_b = translate_2d(quater_b, Vector2(2, -0.5 + shift))

	quater_a.append_array([Vector2(0, 0)])
	quater_a.append_array(quater_b)
	return quater_a

func regenerate():
	for child in get_children():
		print("removing ", child)
		remove_child(child)
		child.free()
		
	csg_geometry()
	print("geometry spawned")


func spawn_cap(resolution: int, t: Transform3D, name: String) -> void:
	var cap_0 = CSGPolygon3D.new()
	self.add_child(cap_0)
	cap_0.owner = get_tree().edited_scene_root

	cap_0.name = name
	cap_0.mode = CSGPolygon3D.MODE_SPIN;
	cap_0.spin_degrees = 180
	cap_0.polygon = half_bump(resolution)
	cap_0.transform = t
	cap_0.spin_sides = resolution

@export var p_diameter: float = 7;
func csg_geometry():
	var resolution = mesh_resolution;
	var _profile = bump(resolution)
	
	var ts: = Libgeo.Shapes.circle_4d(64, 0.75, false)
	var t_scale: = Transform3D.IDENTITY.scaled(Vector3.ONE*p_diameter)
	#Libgeo.Math.form_sxform(ts, t_scale)
	ts = Libgeo.Math.ts_xform_orgin(ts, t_scale)
	ts = Libgeo.Math.ts_scale_along(ts, p_scale_curve)
	
	var tranform_polygon = CSGAlongTransform.new()
	self.add_child(tranform_polygon)
	tranform_polygon.owner = get_tree().edited_scene_root
	
	tranform_polygon.name = "tranformed_profile"
	tranform_polygon.polygon = _profile
	tranform_polygon.transform_data = Libgeo.Interop.Ts2Fs(ts)

	# var cap_0 = CSGPolygon3D.new()
	# self.add_child(cap_0)
	# cap_0.owner = get_tree().edited_scene_root

	# cap_0.name = "cap_0"
	# cap_0.mode = CSGPolygon3D.MODE_SPIN;
	# cap_0.spin_degrees = 180
	# cap_0.polygon = half_bump(resolution)
	# cap_0.transform = ts.get(len(ts) - 1)

	var first_t: = ts[0];
	first_t.basis.x = -first_t.basis.x
	first_t.basis.z = -first_t.basis.z
	spawn_cap(resolution, first_t, "cap_0")

	var last_t: = ts[len(ts) - 1];
	spawn_cap(resolution, last_t, "cap_1")

func test_geometry() -> void:
	var csg_polygon = CSGPolygon3D.new()
	add_child(csg_polygon)
	csg_polygon.owner = get_tree().edited_scene_root
	csg_polygon.name = "shape_test"

	# var t_data = Libgeo.Shapes.circle4D(48, 0.75, false)
	var t_data = Libgeo.Shapes.circle_4d(48, 0.75, false)
	print("len of t data was: ", len(t_data))
	var scale_t = Transform3D.IDENTITY.scaled(Vector3(3,3,3))
	t_data = Libgeo.Math.ts_xform_orgin(t_data, scale_t)
	var path = as_path(t_data)
	csg_polygon.mode = CSGPolygon3D.MODE_PATH
	csg_polygon.path_node = path.get_path()


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
