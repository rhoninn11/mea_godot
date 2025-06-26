extends Area3D

@export var hmm = "nie wiem, to jakieś dane"
@onready var particles = $GPUParticles3D

func trigger() -> void:
	particles.restart()
	print(hmm)


func _on_area_entered(area: Area3D) -> void:
	trigger()
