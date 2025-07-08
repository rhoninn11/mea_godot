extends Node2D

@onready var sprite: Sprite2D = $img
@onready var controlable: Sprite2D = $controlable
var image: Image = Image.new()
var tex: Texture2D = ImageTexture.new()

var phases: Array[float]
var dyn_sprites: Array[Sprite2D]

var images: Array[ImageTexture]
const slot_num = 12
const sprite_num = 10
const tekstury: Dictionary[String, String] = {
	"jerry": "res://textures/a.png",
	"panicz": "res://textures/b.png",
	"skarpeta": "res://textures/c.png",
}
const tex_num = len(tekstury)

@export var speed: float = 500

@export var has_control:bool = false

func _ready():
	ControlContext.register(self)
	var arrs = [phases, dyn_sprites]
	for arr in arrs:
		arr.resize(sprite_num)

	for i in range(0,sprite_num):
		dyn_sprites[i] = Sprite2D.new()
		add_child(dyn_sprites[i])
		print(dyn_sprites[i])
		print(phases[i])
	
	images.resize(tex_num)
	var i = 0
	var img = Image.new()
	for tag in tekstury:
		var err = img.load(tekstury[tag])
		if err != 0:
			print("!!! failed loading image: ", tag)
		images[i] = ImageTexture.new()
		images[i].set_image(img)
		i += 1

	initials()

	

func initials():
	for i in range(0, len(phases)):
		var phase: float = float(i)/slot_num
		phases[i] = phase*3.1415*2

	for i in range(0, len(dyn_sprites)):
		var i_safe = i%tex_num
		dyn_sprites[i].texture = images[i_safe]
		dyn_sprites[i].scale = Vector2(0.1, 0.1)
		dyn_sprites[i].z_index = i
		

func pos_from_phase():
	var r = 50
	const base_pos = Vector2(300,300)
	for i in range(0, len(phases)):
		var x = cos(phases[i]) * r
		var y = sin(phases[i]) * r
		dyn_sprites[i].position = base_pos + Vector2(x, y)


func _process(delta: float) -> void:
	for i in range(0, len(phases)):
		phases[i] += delta
	
	pos_from_phase()
	update_pos(controlable, delta)

func update_pos(sprite: Sprite2D, delta: float) -> void:
	if not has_control:
		return
	
	var vec = Input.get_vector("left", "right", "up", "down")
	if vec != Vector2.ZERO:
		vec = vec * delta * speed
		sprite.translate(vec)


func pass_control() -> void:
	has_control = true
	
func take_control() -> void:
	has_control = false


func _on_area_2d_body_exited(body: Node2D) -> void:
	ControlContext.deactivate_alt()
	print("player exited area")
