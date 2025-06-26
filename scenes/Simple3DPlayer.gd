extends Node3D
class_name Simple3DPlayer

@export var speed: float = 4.5
var var_speed: float = speed

@onready var speed_t: Timer = $speed_timer
@onready var fonk_music: AudioStreamPlayer = $fonk_music

var speed_up: bool = false
var speed_up_last: bool = false
@export var fade: float = 1
var var_fade: float = 0

var playing: bool = false
var loud: bool = false
@export var max_volume: float = -3
@export var mute_volume: float = -120
var just_speed_up: bool = false

var has_control:bool = false

func _ready() -> void:
	fonk_music.finished.connect(_on_track_finished)
	ControlMng.register(self)
	ControlMng.set_main(self)
	var t = create_tween()

func _process(delta: float) -> void:
	update_speed()
	update_pos(delta)
	update_playback(delta)


func update_pos(delta: float) -> void:
	if not has_control:
		return
	
	var move = Input.get_vector("up", "down", "left", "right")
	var move_3d = Vector3(move.y, 0, move.x)
	
	if move_3d != Vector3.ZERO:
		move_3d = move_3d*delta*var_speed
		self.translate(move_3d)
	
func update_speed() -> void:
	speed_up_last = speed_up
	speed_up = speed_t.time_left > 0
	
	if speed_up:
		var_speed = speed * 2
	else:
		var_speed = speed
		
	just_speed_up = speed_up and not speed_up_last

func _on__interaction_area_entered(area: Area3D) -> void:
	speed_t.start()
	print("i co aasdasdktywuj")

func update_playback(delta: float) -> void:
	if just_speed_up:
		if not playing:
			fonk_music.play()
			playing = true
		fonk_music.volume_db = max_volume
		loud = true
	
	if speed_up:
		var_fade = 0
		return
		
	if not loud:
		return
		
	var_fade += delta
	if var_fade > fade:
		var_fade = fade
		loud = not true
	
	var progress = var_fade/fade
	var volume = max_volume + progress*mute_volume
	fonk_music.volume_db = volume
	

func _on_track_finished() -> void:
	if loud:
		fonk_music.play()
	else:
		playing = not true
		
func pass_control() -> void:
	has_control = true
	
func take_control() -> void:
	has_control = false
