extends Node2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@export var steam_is: bool = true

var garnek_level: int = 0

func steam_level_up() -> void:
	if garnek_level == 1:
		particles.amount = 24
		var p_mat = particles.process_material as ParticleProcessMaterial
		p_mat.initial_velocity_min = 100
		p_mat.initial_velocity_max = 100
		p_mat.spread = 20
	if garnek_level == 0:
		particles.amount = 8
		steam_is = true
	
	garnek_level += 1
		

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	particles.emitting = steam_is


func start_boiling() -> void:
	print("+++ no to podgrzewamy")
	steam_level_up()
	
func grab_hot_pot() -> void:
	steam_is = true
	particles.amount = 2
