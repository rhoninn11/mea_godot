extends Node2D
class_name Ludek
@onready var sprite = $sprite_ludka
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var body: LudekHolder = $sprite_ludka/riggid
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
var holded: bool = false
var holded_last: bool = false
var holder: Node2D = null
var ludek_data: LudekData = null

enum States {
	PREWAITING, 
	WAITING, 
	WALKING, 
	ALMOST_AT_HOME
}

@export var walking_sound: AudioStream
@export var state: States = States.WAITING
var initial_pos: Vector2 = Vector2.ZERO

signal left_screan();

func interaction_begin(node: Node2D) -> void:
	holded = true
	holder = node

func interaction_end() -> void:
	holded = false

func config(data: LudekData) -> void:
	ludek_data = data
	state = States.PREWAITING

func initialize(data: LudekData) -> void:
	sprite.texture = data.texture
	if body.is_in_group("family_member") != data.is_family_member:
		if data.is_family_member:
			body.add_to_group("family_member");
		else:
			body.remove_from_group("family_member");
	
	audio.stream = data.clip

func you_are_capitan_now() -> void:
	state = States.WAITING

func _ready() -> void:
	if ludek_data:
		initialize(ludek_data)
	body.hold_start_sig.connect(self.interaction_begin)
	body.hold_end_sig.connect(self.interaction_end)

func _process(delta: float) -> void:
	update(delta)
	holded_last = holded
	
func update(delta: float) -> void:
	if state == States.WAITING:
		#sprite.scale = Vector2(1.5, -1)
		if holded and not holded_last:
			var pitch_bend = randf() 
			audio.pitch_scale = 1 + pitch_bend * 0.5
			audio.play(0)
		
		if holded:
			anim.play("excited")
			sprite.scale = Vector2(1, -1)
			# anim.current_animation = "excited"
			var anim_pos = anim.current_animation_position
			var diff = self.position - holder.position
			#print("diff: ", diff.x)
			if diff.x > 200:
				state = States.WALKING
				audio.stream = walking_sound
				audio.pitch_scale = 1
				
				
		else:
			if body.hover:
				sprite.scale = Vector2(1.5, -1);
			else:
				sprite.scale = Vector2(1, -1);
			anim.play("RESET")
	#else:
		#sprite.scale = Vector2(1, -1)
			
	if state == States.WALKING:
		anim.play("walking")
		if not audio.playing:
			audio.play()
			
		var pos = self.position
		pos.x += delta * -400
		self.position = pos
		#print("pos: ", pos.x)
		if pos.x < -50:
			state = States.ALMOST_AT_HOME
			anim.play("RESET")
			audio.stop()
			left_screan.emit()
