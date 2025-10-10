@tool
extends MultiMeshInstance3D

@export_tool_button("regenerate") var btn = regenerate
@export_tool_button("regenerate_ok") var btn_ok = regenerate_ok

@export var num: int = 8;
@export var mesh_src: Mesh;
@export var fill: float = 0.5;

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

func regenerate():
	var color_data := Libcolor.Utils.gradient(0.1, 0.6, num)
	regenerate_with_color(color_data)
	print("+++ regenerate called")

func regenerate_ok():
	var ok_0 := Vector3(0.1, 0.62, 0.2)
	var ok_1 := Vector3(0.6, 0.62, 0.2)
	var color_data := Libcolor.Utils.ok_gradient(ok_0, ok_1, num)
	regenerate_with_color(color_data)
	print("+++ ok regeneratge called")

var timer: float = 0;
func _process(delta: float) -> void:
	const recalc_every = 1
	if Engine.is_editor_hint():
		return

	timer += delta;
	if timer > recalc_every:
		timer -= recalc_every	
		transform_bytes = calc_positions(randf()*8)
		print(len(color_bytes))
		update_buffer()
		print("data updated")

var transform_bytes: PackedFloat32Array
var color_bytes: PackedFloat32Array

func update_buffer() -> void:
	assert(self.multimesh);
	multimesh.buffer = merge_instance_data(transform_bytes, color_bytes)

func calc_positions(offset: float) -> PackedFloat32Array:
	var spots = Libgeo.Shapes.circle_4d(num, fill, false);
	spots = Libgeo.Math.ts_xform_orgin(spots, Libgeo.Math.scale_m(5));
	var translation = Transform3D.IDENTITY
	translation.origin.y = offset;
	spots = Libgeo.Math.ts_xform_orgin(spots, translation)
	return Libgeo.Interop.Ts2Fs(spots)

func regenerate_with_color(color_data: PackedFloat32Array):
	assert(mesh_src);
	if not multimesh:
		multimesh = MultiMesh.new()
		var shader_material: = ShaderMaterial.new();
		shader_material.shader = load("res://shaders/for_instance.gdshader");
		self.material_overlay = shader_material;

	transform_bytes = calc_positions(0);
	color_bytes = color_data;


	multimesh.instance_count = 0;
	multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	multimesh.use_colors = true;

	multimesh.instance_count = num;
	update_buffer()
	multimesh.mesh = self.mesh_src;
