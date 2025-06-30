extends Node2D

@export var test_enabled: bool = false
@onready var body: RigidBody2D = $RigidBody2D

var passed: float = 0
var triggered: bool = false
func _process(delta: float) -> void:
	passed += delta
	if test_enabled and passed > 0.5 and not triggered:
		triggered = true
		stop_simulation()

func stop_simulation() -> void:
	assert(body != null)
	
	body.freeze = true
	body.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	print("nastąpiło zamrożenie")
