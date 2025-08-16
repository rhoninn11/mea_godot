@tool
extends Node2D

@export var contact_area: Area2D = null
@export var view_area: Area2D = null

@export var steps: Array[Texture2D] = []
@export var target_pos: Vector2
@export var curve: Curve
@export var gaze_delta: float

var time: float = 0
var local_sprites: Array[Sprite2D] = []

var used: bool = false
var use_progresion: float = 0

signal node_spoted(node: Node2D)
signal node_left(node: Node2D)

func on_node_spoted(node: Node2D) -> void:
	print("+++ new node spoted")
	node_spoted.emit(node)

func on_node_left(node: Node2D) -> void:
	node_left.emit(node)
	pass

func on_observer_present(node: Node2D) -> void:
	if node.is_in_group("vision"):
		print("+++ observer showed up")
		start_using()

func on_observer_left(node: Node2D) -> void:
	if node.is_in_group("vision"):
		print("+++ observer left view")
		stop_using()

func start_using() -> void:
	used = true
	
func stop_using() -> void:
	used = false

func _ready() -> void:
	if Engine.is_editor_hint():
		config()
		return
	
	config()
	contact_area.body_entered.connect(on_node_spoted)
	contact_area.body_exited.connect(on_node_left)

	view_area.area_entered.connect(on_observer_present)
	view_area.area_exited.connect(on_observer_left)

	for step in steps:
		var new = Sprite2D.new()
		new.texture = step
		new.z_index = 20
		self.add_child(new)
		local_sprites.append(new)
		
		
		
func config() -> void:

	var contact_pos = self.target_pos - self.position
	contact_area.position = contact_pos


var elapsed: float = 0;

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		config()
		assert(curve)
		return
		
	beam_update(delta)

	

func beam_update(delta: float) -> void:
	const transition_speed = 2
	if used:
		use_progresion += delta * transition_speed
	else:
		use_progresion -= delta * transition_speed
	use_progresion = clampf(use_progresion, -0.01, 1)
	
	var lin_a: float = 1.1
	var lin_b: float = -0.1
	var anim_pos: float = use_progresion*lin_a + lin_b
	
	const freq = 0.2
	time += delta

	var look_at := self.target_pos - self.position
	
	# var p1 := self.position
	# var p2 := target_pos
	# print("x: ", p1.x, ", y: ", p1.y, ", x: ", p2.x, ", y: ", p2.y)

	var arg := TAU*freq*time	
	var vscale := Vector2(3, 1) * gaze_delta
	var off_by := Vector2(cos(arg),sin(arg)) * vscale
	look_at += off_by

	var step_num = len(steps)
	
	for i in range(step_num):
		var w: float = float(i)/float(step_num - 1)
		
		var pos = lerp(Vector2.ZERO, look_at, w)
		var sprite_scale = curve.sample(w)
		local_sprites[i].position = pos
		local_sprites[i].scale = Vector2(sprite_scale, 1)
		
		var alpha: float = 0
		if anim_pos >= w:
			alpha = 1
		
		local_sprites[i].self_modulate = Color(Color.WHITE, alpha)
	
