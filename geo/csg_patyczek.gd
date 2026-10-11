@tool
extends Node3D

class StickSizeing:
	var len: float
	var w: float
	var h: float
	
	func _init() -> void:
		self.len = 13
		self.w = 1.2
		self.h = 0.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


@export_tool_button("regenerate") var regenerate_btn = regenerate
@export_tool_button("clear") var clear_btn = clear

func clear():
	for child in get_children():
		print("removing ", child.name)
		remove_child(child)
		child.free()

func regenerate():
	clear()
	var canvas := spawn_canvas(self, "main")
	spawn_stick(canvas)
	await get_tree().create_timer(1.0).timeout
	var canvas1 := spawn_canvas(self, "side")
	sequencec(canvas1, get_mesh(canvas))
	
func get_mesh(combiner: CSGCombiner3D) -> ArrayMesh:
	print("combiner: ", combiner)
	var mesh := combiner.bake_static_mesh()
	print("export val: ", mesh)
	return mesh

func spawn_canvas(to: Node3D, name: StringName) -> CSGCombiner3D:
	var combiner = CSGCombiner3D.new()
	to.add_child(combiner)
	combiner.owner = get_tree().edited_scene_root
	combiner.name = name
	return combiner
	
func spawn_stick(to: Node3D):
	var sizing := StickSizeing.new()
	spawn_middle(to, sizing)
	spawn_side(to, sizing, false)
	spawn_side(to, sizing, true)

func spawn_middle(to: Node3D, s: StickSizeing) -> CSGBox3D:
	var long = CSGBox3D.new()
	to.add_child(long)
	long.owner = get_tree().edited_scene_root
	long.size = Vector3(s.len-s.w, s.h, s.w)
	
	long.name = "middle"
	return long 

func spawn_side(to: Node3D, s: StickSizeing, l: bool) -> CSGCylinder3D:
	var side = CSGCylinder3D.new()
	to.add_child(side)
	
	side.owner = get_tree().edited_scene_root
	var spot := Vector3((s.len - s.w)/2, 0, 0)
	var sufix := "_r"
	if l:
		sufix = "_l"
		spot.x = -spot.x
	
	side.name = "side" + sufix
	side.transform.origin = spot
	side.radius = s.w/2
	side.height = s.h
	side.sides = 32
	
	return side 

func sequencec(to: Node3D, mesh: ArrayMesh) -> void:
	var hmm: Array[String] = ["0", "1", "2", "3", "4", "5", "6", "7"]
	var inst
	for i in range(8):
		var stamp := CSGMesh3D.new()
		to.add_child(stamp)
		stamp.owner = get_tree().edited_scene_root
		stamp.name = "stamp_" + hmm[i]
		stamp.transform.origin = Vector3(1,2,i*3)
		stamp.mesh = mesh
