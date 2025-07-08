extends XROrigin3D


var xr_interface: XRInterface
func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED)
		
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized")
