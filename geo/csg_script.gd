@tool
extends CSGCombiner3D

@export var profile: PackedVector2Array
@export var turn_val: float = 0
@export var fill: float = 0.5
@export_tool_button("regenerate") var regenerate_btn = regenerate

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
		
	var geometry = csg_geometry()
	print("geometry spawned")

func path_mode(p: CSGPolygon3D, resolution: int) -> void:
	var path_node = path_3d()

	p.path_node = path_node.get_path()
	p.mode = CSGPolygon3D.MODE_PATH
	p.path_interval_type = CSGPolygon3D.PathIntervalType.PATH_INTERVAL_SUBDIVIDE
	
func xform_mode(p: CSGPolygon3D, resolution: int) -> void:
	var ts = Libgeo.Helpers.circle4D(32, 0.5, true)
	var efs = Libgeo.Helpers.Ts2Fs(ts)
	pass

func csg_geometry() -> CSGAlongTransform:
	var resolution = 8
	var _profile = bump(resolution)
	
	var tranform_polygon = CSGAlongTransform.new()
	self.add_child(tranform_polygon)
	tranform_polygon.owner = get_tree().edited_scene_root
	
	tranform_polygon.name = "tranformed_profile"
	tranform_polygon.polygon = _profile
	var ts = Libgeo.Helpers.circle4D(32, 0.5, true)
	var scale = Transform3D.IDENTITY.scaled(Vector3(3,3,3))
	ts = Libgeo.Helpers.TsoXT(ts, scale)
	tranform_polygon.transform_data = Libgeo.Helpers.Ts2Fs(ts)
	
	return tranform_polygon

func path_3d() -> Path3D:
	var path_3d_node = Path3D.new()
	self.add_child(path_3d_node)
	path_3d_node.owner = get_tree().edited_scene_root
	
	var path = Curve3D.new()
	var circle_points = circle(32, true, 0.5)
	circle_points = scale_2d(circle_points, Vector2(2,2))

	var _len = len(circle_points)
	for i in range(len(circle_points)):
		var _in: Vector3 = Vector3.ZERO
		var _out: Vector3 = Vector3.ZERO
		#if i == 0:
			#_out = Vector3.FORWARD
		var p2 = circle_points[i]
		path.add_point(Vector3(p2.x, 0, p2.y), _in, _out)
	
	
	path_3d_node.name = "half_circle"
	path_3d_node.curve = path
	return path_3d_node


func t2farr(t: Transform3D) -> PackedFloat32Array:
	var buffer: PackedFloat32Array
	buffer.resize(12)
	var i: int = 0
	var varr: Array[Vector3] = [t.basis[0], t.basis[1], t.basis[2], t.origin]
	for vec in varr:
		for val in [vec.x, vec.y, vec.z]:
			buffer[i] = val
			i += 1
	return buffer
