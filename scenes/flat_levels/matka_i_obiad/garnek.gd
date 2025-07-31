extends Node2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@export var steam_is: bool = true
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	particles.emitting = steam_is


func start_boiling() -> void:
	steam_is = true
