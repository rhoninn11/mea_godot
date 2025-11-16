@tool

extends Node2D

@export var x_size: float = 200
@export var y_size: float = 200
func spawn_debug_path(to: Node2D) -> void:
	var r: float = 20
	var tri_size := Vector2(x_size, y_size)

	# opt 1
	var convex := Libgeo.Shapes.Profiles.right_triangle(tri_size)
	# opt 2
	convex = Libgeo.Shapes.Profiles.square(1)
	Libgeo.Math.ops2d_scale(convex, Vector2(x_size, y_size))
	#
	var profile := Libgeo.Shapes.Profiles.convex_rounded(convex, r) 
	profile_as_path(to, profile, true, Color.GREEN)
	var angle_data := Libgeo.Math.calc_angles(convex)
	profile_as_path(to, convex, true, Color.VIOLET)

	var n = len(convex)
	var full_circle = Libgeo.Shapes.phase_1d(16, 1.0)
	for i in range(n):
		var prev = convex[i]
		var curr_idx = (i + 1)%n
		var curr = convex[curr_idx]
		var next = convex[(i + 2)%n]

		var profile3 := Libgeo.Math.not_identified(prev, curr, next, 100)
		Libgeo.Math.ops2d_move(profile3, curr)
		profile_as_path(to, profile3, false, Color.BEIGE)

		var interm := r/sin(angle_data[curr_idx].x/2)
		var profile4 := Libgeo.Math.not_identified2(prev, curr, next, interm)

		Libgeo.Math.ops2d_move(profile4, curr)
		profile_as_path(to, profile4, false, Color.RED)
		
		var circ  := Libgeo.Shapes.phi_circle_2d_pos(full_circle)
		Libgeo.Math.ops2d_scale(circ, Vector2.ONE*r)
		Libgeo.Math.ops2d_move(circ, profile4[1])
		profile_as_path(to, circ, true, Color.YELLOW_GREEN)
	

func profile_as_path(to: Node2D, data: PackedVector2Array, closed: bool, color: Color) -> Line2D:
	assert(len(data) >= 2)
	var profile := Libgeo.Memory.copy(data)
	if closed:
		profile.append(profile[0])
	
	var line = Line2D.new()
	to.add_child(line)
	line.owner = get_tree().edited_scene_root
	line.name = "profile_line"
	line.default_color = color
	line.points = profile
	line.width = 4

	return line

func regenerate() -> void:
	for child in get_children():
		remove_child(child)
		child.free()
	
	spawn_debug_path(self)

var timer: float = 0
var refresh: float = 0.25
@export var freeze: bool = false
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		timer += delta;

	if timer > refresh:
		timer -= refresh
		if not freeze:
			regenerate()
