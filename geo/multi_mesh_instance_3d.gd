@tool
extends MultiMeshInstance3D

@export_tool_button("regenerate") var btn = regenerate
@export_tool_button("regenerate_ok") var btn_ok = regenerate_ok

@export var num: int = 8;
@export var mm: MultiMesh = null;
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

func regenerate_with_color(color_data: PackedFloat32Array):
	assert(mesh_src);
	if not mm:
		mm = MultiMesh.new()

	var spots = Libgeo.Shapes.circle_4d(num, fill, false);
	spots = Libgeo.Math.ts_xform_orgin(spots, Libgeo.Math.scale_m(5));
	# spots = Libgeo.Math.sin_along(spots, Vector3.UP);
	
	# wychodni na to, że jak będę chciał używać dodatkowych danych to trzeba je przeplatać z transformem
	var transform_data := Libgeo.Interop.Ts2Fs(spots);
	# print("transform data: ",len(transform_data))
	# print("color data: ", len(color_data))
	var shared_data = merge_instance_data(transform_data, color_data)
	# print("shared data: ", len(shared_data))

	mm.instance_count = 0;
	mm.transform_format = MultiMesh.TRANSFORM_3D;
	mm.use_colors = true;

	mm.instance_count = num;
	mm.buffer = shared_data;
	# mm.transform_array = possible_buffer
	mm.mesh = self.mesh_src;

	self.multimesh = mm;
	
