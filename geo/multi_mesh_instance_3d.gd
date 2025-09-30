@tool
extends MultiMeshInstance3D

@export_tool_button("regenerate") var btn = regenerate

@export var num: int = 8;
@export var mm: MultiMesh = null;
@export var mesh_src: Mesh;

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
	assert(mesh_src);
	if not mm:
		mm = MultiMesh.new()

	var spots = Libgeo.Shapes.circle_4d(num, 0.5, false);
	spots = Libgeo.Math.ts_xform_orgin(spots, Libgeo.Math.scale_m(5));
	# spots = Libgeo.Math.sin_along(spots, Vector3.UP);
	
	# wychodni na to, że jak będę chciał używać dodatkowych danych to trzeba je przeplatać z transformem
	var transform_data := Libgeo.Interop.Ts2Fs(spots);
	var color_data := Libcolor.Utils.gradient(0.1, 0.6, num);
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
	
