@tool
extends MultiMeshInstance3D

@export_tool_button("regenerate") var btn = regenerate

@export var mm: MultiMesh = null
@export var mesh: Mesh

func regenerate():
	assert(mesh)
	if not mm:
		mm = MultiMesh.new()

	var num = 8
	var spots = Libgeo.Shapes.circle_4d(num, 0.5, false)
	spots = Libgeo.Math.ts_xform_orgin(spots, Libgeo.Math.scale_m(5))
	
	var possible_buffer = Libgeo.Interop.Ts2Fs(spots)

	mm.instance_count = 0
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = num
	mm.buffer = possible_buffer
	mm.mesh = self.mesh

	self.multimesh = mm
	
