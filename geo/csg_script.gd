@tool
extends CSGCombiner3D

@export var profile: PackedVector2Array
@export var turn_val: float = 0
@export var fill: float = 0.5
@export_tool_button("regenerate") var regenerate_btn = regenerate

@export var scale_curve: Curve

# this functions will go to other lib script
func circle(points: int, closed: bool, fill_c: float) -> PackedVector2Array:
	var scratchpad: PackedVector2Array
	if closed:
		points += 1
	scratchpad.resize(points)
	for i in range(points):
		var phase = float(i)/(points-1) * TAU * fill_c
		var circle_point = Vector2(cos(phase), sin(phase))
		scratchpad[i] = circle_point
	return scratchpad

func pie(points: int, fill_c: float) -> PackedVector2Array:
	var crcl = circle(points, true, fill_c)
	if fill_c < 1:
		crcl.append(Vector2.ZERO)
	return crcl
	
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
func bump(resolution: int) -> PackedVector2Array:
	if resolution < 4:
		push_error("+++ bad resolution")

	var half = circle(resolution*2, true, 0.5)
	var quater = circle(resolution, true, 0.25)
	quater.reverse()
		
	var start = rotate_2d(quater, 0.5)
	var end = rotate_2d(quater, 0.75)
	
	start = translate_2d(start, Vector2(2, -0.5))
	end = translate_2d(end, Vector2(-2, -0.5))
	var middle = translate_2d(half, Vector2(0, 0.5))

	start.append_array(middle)
	start.append_array(end)
	return start


func regenerate():
	for child in get_children():
		print("removing ", child)
		remove_child(child)
		child.free()
		
	csg_geometry()
	print("geometry spawned")


func csg_geometry():
	var resolution = 8
	const bigger: float = 7
	var _profile = bump(resolution)
	
	var tranform_polygon = CSGAlongTransform.new()
	self.add_child(tranform_polygon)
	tranform_polygon.owner = get_tree().edited_scene_root
	
	tranform_polygon.name = "tranformed_profile"
	tranform_polygon.polygon = _profile
	var ts = Libgeo.Shapes.circle_4d(64, 0.75, false)
	var scale = Transform3D.IDENTITY.scaled(Vector3(bigger, bigger, bigger))
	ts = Libgeo.Math.ts_xform_orgin(ts, scale)
	ts = Libgeo.Math.ts_scale_along(ts, scale_curve)
	tranform_polygon.transform_data = Libgeo.Interop.Ts2Fs(ts)

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
