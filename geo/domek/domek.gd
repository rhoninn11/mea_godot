@tool
extends CSGCombiner3D

var in_edit: bool = false;
var last_outter_size: Vector3;

@export var update_interval: float = 0.1
@export var wall_thickness: float = 0.1
@export var csg_scale: float = 4;

@export var collistion: CollisionShape3D = null
@export_tool_button("bake_collision", "Callable") var btn_1 = bake_c_shape;
func bake_c_shape() -> void:
	if collistion == null:
		remove_type_nodes("CollisionShape3D")		

		collistion  = CollisionShape3D.new()
		self.get_parent().add_child(collistion);
		collistion.name = "csg_colision";
		collistion.owner = get_tree().edited_scene_root;

	collistion.shape = self.bake_collision_shape()
	print("colision backed?")

@export var geo_arr: Array[CSGBox3D] = []
@export_tool_button("editor_spawn", "Callable") var btn_0 = editor_spawn;
func editor_spawn() -> void:
	for obj in self.get_children():
		if obj.is_class("CSGPrimitive3D"):
			obj.queue_free();

	var scene_owner: = get_tree().edited_scene_root;
	geo_arr.clear();
	for i in range(4):
		geo_arr.append(CSGBox3D.new());
		self.add_child(geo_arr[i]);
		geo_arr[i].name = "geo_%03d" % [i];
		geo_arr[i].owner = scene_owner;
		print("added node: %s" % [geo_arr[i]]);
	
	for i in range(1, 4):
		geo_arr[i].operation = CSGShape3D.OPERATION_SUBTRACTION;

	var bldn_size = Vector3(3, 5, 3)*csg_scale;	
	var bldn_off = Vector3(0, bldn_size.y*0.5, 0);
	geo_arr[0].size = bldn_size;
	geo_arr[0].transform.origin = bldn_off;

	var cutout_size = Vector3(2, 2, 2)*csg_scale;
	geo_arr[2].size = cutout_size;
	geo_arr[3].size = cutout_size;
	geo_arr[2].position = bldn_size/2 + bldn_off;
	geo_arr[3].position = -bldn_size/2 + bldn_off;

	last_outter_size = Vector3.ZERO;
	

func edit_activity() -> void:
	assert(len(geo_arr) == 4);
	var outer: = geo_arr[0];
	var inner = geo_arr[1];

	if last_outter_size == outer.size: return;
	last_outter_size = outer.size;
	

	inner.size = last_outter_size - (Vector3.ONE * wall_thickness * 2);
	inner.position = outer.position


func _ready() -> void:
	in_edit = Engine.is_editor_hint();
	if in_edit: return;	
	
	print("sanity")

func _process(_delta: float) -> void:
	if not in_edit: return;
	edit_activity()
	

func remove_type_nodes(type_name: String) -> void:
	for obj in self.get_children():
		if obj.is_class(type_name):
			obj.queue_free();
