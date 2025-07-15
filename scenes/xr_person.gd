extends XROrigin3D


var xr_interface: XRInterface
func _ready() -> void:
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
