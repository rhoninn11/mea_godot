extends XROrigin3D

@onready var label =  $left/MeshInstance3D/Label3D
@onready var head = $XRCamera3D
@onready var left: XRController3D = $left
@onready var right: XRController3D = $right
@onready var root_point = $root_point


var xr_interface: XRInterface
var offset: float = 0
@export var neglect: bool = false

func _ready() -> void:
	if neglect: 
		return
		
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and not xr_interface.is_initialized():
		print("OpenXR not initialized")
		return

	xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ADDITIVE
	DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED)	
	get_viewport().transparent_bg = true
	get_viewport().use_xr = true
	
	var pt_supperted = xr_interface.is_passthrough_supported()
	print("passthrough supported: ", pt_supperted)
	if pt_supperted:
		xr_interface.start_passthrough()
	
	var pt_enabled = xr_interface.is_passthrough_enabled()
	print("passthrough enable: ", pt_enabled)

var moved: bool = false
var rotated: bool = false
var total_rotation: float = 0
func _process(delta: float) -> void:
	if neglect:
		return
		
	var hmm = head.transform.origin
	label.text = "head height: " + str(hmm.y).pad_decimals(2)
	
	
	var head_pos = head.transform.origin
	head_pos.y = 0
	root_point.transform.origin = head_pos

	var val = left.get_vector2("primary")
	if not moved and abs(val.y) > 0.5:
		moved = true
		self.translate(Vector3(0, 0, -sign(val.y)))
		
	if abs(val.y) < 0.5:
		moved = false

	if not rotated and abs(val.x) > 0.5:
		rotated = true
		var amount = sign(-val.x)
		total_rotation += amount * (TAU/float(12))
		self.transform.basis = Basis.IDENTITY.rotated(Vector3.UP, total_rotation)
		
	if abs(val.x) < 0.5:
		rotated = false
