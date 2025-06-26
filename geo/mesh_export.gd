@tool
extends EditorScript

var reload_counter: int = 0

@export_tool_button("export") var export = export_mesh_resource 

func find_geo_mng() -> CSGCombiner3D:
	var scene = get_scene()
	var nodes = scene.get_children()
	
	var scriptable_geo: CSGCombiner3D
	for node in nodes:
		if node is CSGCombiner3D:
			scriptable_geo = node
			break
	
	return scriptable_geo

func export_mesh_resource():
	var geo_mng = find_geo_mng()
	if geo_mng != null:
		csg_2_mesh(geo_mng)
	
func csg_2_mesh(geo_mng: CSGCombiner3D) -> void:
	if geo_mng == null:
		print("!!! failed to find geo_mng")
		return
	
	var exported_mesh: ArrayMesh = geo_mng.bake_static_mesh()
	var surfaces_num := exported_mesh.get_surface_count()
	if surfaces_num == 0:
		print("!!! no surface")
		return
	
	var arrays = exported_mesh.surface_get_arrays(0)
	if len(arrays) == 0:
		print("!!! bad underlaying array")
		return
	
	print("+++ verts count ", len(arrays[Mesh.ARRAY_VERTEX]))
	
	var timestump = Time.get_datetime_string_from_system(true).replace(":", "-").replace(" ", "_")
	var res_path = "res://tmp/geo_%s.tres" % timestump
	ResourceSaver.save(exported_mesh, res_path)
	print("+++ geometry saved at ", res_path)
	
	
