extends RigidBody2D

var position_provider: Node2D = null
var in_hold_state: bool = false
@export var debug: bool = false

func _process(delta: float) -> void:
	pass
	
func hold_start(by_node: Node2D) -> void:
	modulate = Color(1, 0.6, 0.6, 1)
	gravity_scale = 0
	position_provider = by_node
	in_hold_state = true
	can_sleep = false
	
func hold_end() -> void:
	modulate = Color(1,1,1,1)
	gravity_scale = 1
	position_provider = null
	in_hold_state = false
	can_sleep = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not in_hold_state:
		if debug:
			print(state.linear_velocity, state.step)
		return
	
	var oa = state.transform.origin
	var ob = position_provider.transform.origin
	var delta_distance = (ob - oa)*1.2
	state.linear_velocity = delta_distance/state.step
	
