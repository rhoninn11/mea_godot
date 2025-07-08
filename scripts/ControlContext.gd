extends Node
class_name ControlContext

static var _registered_nodes:Array[Node] = []
static var main_node:Node
static var alt_node:Node
static var main_active:bool
static var methods:Array[String] = ["pass_control", "take_control"]

static var control_state := Enums.ControlState.TRAVEL 

static func register(n:Node) -> void:
	var method_num: int = len(methods)
	var confirmed:Array[bool]
	confirmed.resize(len(methods))
	
	if not _registered_nodes.has(n):
		var script_data = n.get_script()
		var m_list = script_data.get_script_method_list()
		var has_mehtod:bool = false
		
		for method in m_list:
			for i in range(method_num):
				if method.name == methods[i]:
					confirmed[i] = true
				
		for i in range(method_num):
			assert(confirmed[i], "Node (" + n.name + ") missing " + methods[i])
		
		_registered_nodes.append(n)

static func set_main(n:Node) -> void:
	if n in _registered_nodes:	
		main_node = n
		main_active = true
		main_node.pass_control()
		
	
static func activate_alt(n:Node) -> void:
	if not main_active:
		return
	
	if n in _registered_nodes:
		alt_node = n
		main_node.take_control()
		alt_node.pass_control()

static func deactivate_alt() -> void:
	if alt_node in _registered_nodes:
		alt_node.take_control()
		main_node.pass_control()

func _process(delta: float) -> void:
	print("say what?")
