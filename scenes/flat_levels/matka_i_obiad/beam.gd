@tool
extends Node2D
@export var steps: Array[Texture2D] = []
@export var target_pos: Vector2
@export var curve: Curve
@export var gaze_delta: float
@export var contact: Area2D

var time: float = 0
var local_sprites: Array[Sprite2D] = []

signal node_spoted(node: Node2D)
signal node_left(node: Node2D)

func on_node_spoted(node: Node2D) -> void:
	print("+++ new node spoted")
	node_spoted.emit()

func on_node_left(node: Node2D) -> void:
	node_left.emit()

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if contact:
		print("połączono z oknem")
		contact.body_entered.connect(on_node_spoted)
		contact.body_exited.connect(on_node_left)

	for step in steps:
		var new = Sprite2D.new()
		new.texture = step
		self.add_child(new)
		local_sprites.append(new)
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint() and contact != null:
		var contact_pos = self.target_pos - self.position
		contact.position = contact_pos
		return
	
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
		var w = float(i)/float(step_num - 1)
		
		var pos = lerp(Vector2.ZERO, look_at, w)
		var scale = curve.sample(w)
		local_sprites[i].position = pos
		local_sprites[i].scale = Vector2(scale, 1)
