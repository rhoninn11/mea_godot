extends CharacterBody2D

@onready var sprite = $".."
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"
@onready var root: Node2D = $"../.."
var holded: bool = false
var holder: Node2D = null

enum States {WAITING, WALKING, ALMOST_AT_HOME}

var state: States = States.WAITING
var initial_pos: Vector2 = Vector2.ZERO
var hover: bool = false

func hold_start(node: Node2D) -> void:
	holded = true
	holder = node

func hold_end() -> void:
	holded = false

func _ready() -> void:
	#initial_pos = self.position
	pass

func say_hay() -> void:
	print("hey")
	
func say_ho() -> void:
	print("ho")

func _process(delta: float) -> void:
	if state == States.WAITING:
		#sprite.scale = Vector2(1.5, -1)
		if holded:
			anim.play("excited")
			# anim.current_animation = "excited"
			var anim_pos = anim.current_animation_position
			var diff = root.position - holder.position
			#print("diff: ", diff.x)
			if diff.x > 200:
				state = States.WALKING
				
		else:
			anim.play("RESET")
	#else:
		#sprite.scale = Vector2(1, -1)
			
	if state == States.WALKING:
		anim.play("walking")
		var pos = root.position
		pos.x += delta * -100
		root.position = pos
		#print("pos: ", pos.x)
		if pos.x < 0:
			print("left view")
			state = States.ALMOST_AT_HOME
			anim.play("RESET")
