@tool
extends Node

var reload_counter: int = 0

@export_tool_button("export") var export = export_mesh_resource

@export var dural_geo: CSGCombiner3D = null;

func export_mesh_resource():
	assert(dural_geo);
	csg_2_mesh(dural_geo, self.name);
	
func csg_2_mesh(geo_mng: CSGCombiner3D, name: String) -> void:
	var exported_mesh: ArrayMesh = geo_mng.bake_static_mesh()
	var surfaces_num := exported_mesh.get_surface_count()
	assert(surfaces_num > 0)
	
	var arrays = exported_mesh.surface_get_arrays(0)
	if len(arrays) == 0:
		print("!!! bad underlaying array")
		return
	
	print("+++ verts count ", len(arrays[Mesh.ARRAY_VERTEX]))
	
	var mesh_res_path = "res://tmp/geo_%s.tres" % [name]
	var glb_res_path = "res://tmp/geo_%s.glb" % [name]
	ResourceSaver.save(exported_mesh, mesh_res_path)
	print("+++ geometry saved at ", mesh_res_path)


	var v_mesh: = MeshInstance3D.new();
	v_mesh.mesh = exported_mesh;
	var g_doc: = GLTFDocument.new();
	var g_state: = GLTFState.new();

	var e0 = g_doc.append_from_scene(v_mesh, g_state);
	var e1 = g_doc.write_to_filesystem(g_state, glb_res_path);
	if e1 == OK:
		print("+++ geometry :D saved at ", glb_res_path);
	else:
		print("+++ failed to save");
	print(e0, " ", e1);
	
	
