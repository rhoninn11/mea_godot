@tool
extends MultiMeshInstance3D

@export_tool_button("regenerate_ok") var btn_ok = regenerate_ok

@export var num: int = 8;
@export var mesh_src: Mesh;
@export var fill: float = 0.5;
@export var global: bool = false;

var m_xform_bytes: PackedFloat32Array
var m_color_bytes: PackedFloat32Array

func merge_instance_data(transforms: PackedFloat32Array, colors: PackedFloat32Array) -> PackedFloat32Array:
	var n = num

	var shared_data: PackedFloat32Array
	shared_data.resize(n*16)

	for i in range(n):
		var o_i = i * 16
		var t_i = i * 12
		var c_i = i * 4
		for jj in range(12):
			shared_data.set(o_i+jj, transforms.get(t_i+jj))
		
		for jj in range(4):
			shared_data.set(o_i+12+jj, colors.get(c_i+jj))

	return shared_data

func gen_color() -> PackedFloat32Array:
	var ok_0 := Vector3(0.1, 0.62, 0.2)
	var ok_1 := Vector3(0.6, 0.62, 0.2)
	var color_data := Libcolor.Utils.ok_gradient(ok_0, ok_1, num)
	return color_data;

func regenerate_ok():
	assert(mesh_src)
	regenerate_with_color(num);
	m_color_bytes = gen_color();
	m_xform_bytes = calc_positions(0);
	assert(multimesh)
	update_buffer(multimesh, m_xform_bytes, m_color_bytes)

	print("+++ instances regenerated");

var timer: float = 0;
var total_time: float = 0;

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	m_color_bytes = gen_color();

func _process(delta: float) -> void:
	const recalc_every = 1
	if Engine.is_editor_hint():
		return

	timer += delta;
	total_time += delta;
	m_xform_bytes = calc_positions(total_time)
	update_buffer(multimesh, m_xform_bytes, m_color_bytes)


func update_buffer(mm: MultiMesh, xform_b_arr: PackedFloat32Array, color_b_arr: PackedFloat32Array) -> void:
	mm.buffer = merge_instance_data(xform_b_arr, color_b_arr)

@export var y_scale: float = 5;
@export var xz_radius: float = 5;
func calc_positions(offset: float) -> PackedFloat32Array:
	var tforms = Libgeo.Shapes.circle_4d(num, fill, false);
	var prog = Libgeo.Shapes.line_y_4d(num, fill*y_scale);

	var line: = Libgeo.Shapes.line_1d(num);
	var result: = Libgeo.Shapes.empty_1d(num);
	for i in range(num):
		result[i] = line[i]*y_scale + sin(line[i]*TAU+offset)
		# result[i] = line[i]*y_scale;
	
	var tmp: = Libgeo.Shapes.up_1d_to_3d_y(result);
	prog = Libgeo.Shapes.up_3d_to_4d(tmp); 

	tforms = Libgeo.Math.ts_xform_orgin(tforms, Libgeo.Math.scale_m(xz_radius));
	tforms = Libgeo.Math.ts_xforms_origin(tforms, prog);
	if global:
		var g_inv = self.global_transform.affine_inverse();
		for i in range(len(tforms)):
			tforms[i] = g_inv *tforms[i]
	
	return Libgeo.Interop.Ts2Fs(tforms)

func calc_foreign_possition(offset: float) -> PackedFloat32Array:

	
	return calc_positions(offset)

func regenerate_with_color(size: int):
	if not multimesh:
		multimesh = MultiMesh.new()
		var shader_material: = ShaderMaterial.new();
		shader_material.shader = load("res://shaders/for_instance.gdshader");
		self.material_overlay = shader_material;

	multimesh.instance_count = 0;
	multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	multimesh.use_colors = true;

	multimesh.instance_count = size;
	multimesh.mesh = self.mesh_src;
