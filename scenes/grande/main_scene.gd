extends Node3D

@onready var cam: Camera3D = $_kamerka
@onready var display: MeshInstance3D = $display
@onready var scene_2d: Node2D = $_context_2d/scene_2d
@onready var pawn: MeshInstance3D = $pawn

var elapsed: float = 0
var count: int = 0
var tex: ViewportTexture
@export var speed: float = 4.5
@export var hhh: Node2D = scene_2d

func _ready() -> void:
	print("+++ to scena z kamerką")
	elapsed = 0


func print_screan() -> void:
	var img = tex.get_image()
	img.save_png("user://debug1.png")
	print("image saved")

func _process(delta: float) -> void:
	elapsed += delta
	
	if elapsed > 1:
		elapsed -= 1

		count += 1
		if count == 4:
			save_modified_scene()


func save_modified_scene() -> void:
	return
	var dyn_scene_state = PackedScene.new()
	dyn_scene_state.pack(get_tree().current_scene)
	ResourceSaver.save(dyn_scene_state, "res://runtime_tmp/dynamic.tscn")
