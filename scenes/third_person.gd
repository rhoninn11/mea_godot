extends Node3D
class_name ThirdPerson

@export var speed: float = 4.5
var var_speed: float = speed

@onready var speed_t: Timer = $speed_timer
@onready var fonk_music: AudioStreamPlayer = $fonk_music
@onready var rot: RotationComponent = $pawn/RotationComponent

var selected_idx: int = 0;
@onready var hand_arr: Array[Node3D] = [$pawn/right, $pawn/left];
@onready var mesh_arr: Array[MeshInstance3D] = [$pawn/right/mesh, $pawn/left/mesh];

@onready var vert_pos: VerticalComponent = $pawn/VerticalComponent


var speed_up: bool = false
var speed_up_last: bool = false
@export var fade: float = 1
var var_fade: float = 0

var playing: bool = false
var loud: bool = false
@export var max_volume: float = -3
@export var mute_volume: float = -120
var just_speed_up: bool = false

@export var highlight: Material

var has_control:bool = false

func _ready() -> void:
	assert(highlight);
	fonk_music.finished.connect(_on_track_finished);
	ControlContext.register(self);
	ControlContext.set_main(self);
	var t = create_tween();

func _process(delta: float) -> void:
	update_speed()
	update_pos(delta)
	update_playback(delta)
	update_hand()
	
	if Input.is_action_pressed("mouse_capture"):
		ControlContext.control_state = Enums.ControlState.POINTING
	else:
		ControlContext.control_state = Enums.ControlState.TRAVEL
		
	if Input.is_action_just_pressed("tab"):
		switch_hand()


func update_pos(delta: float) -> void:
	if not has_control:
		return
	
	var xform := Transform3D.IDENTITY.rotated(Vector3.UP, rot.fn_turn() + PI) 
	var move := Input.get_vector("up", "down", "left", "right")
	var move_3d := Vector3(move.y, 0, move.x)
	
	if move_3d != Vector3.ZERO:
		move_3d = move_3d*delta*var_speed
		var move_delta :=  xform * move_3d
		self.transform.origin += move_delta
	
	self.transform.basis = xform.basis
	
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

const default_pos:= Vector2(0,1)
func update_hand() -> void:
	var tmp = default_pos + vert_pos.fn_val()
	hand_arr[0].transform.origin = Vector3(-tmp.x, tmp.y, -2)

func switch_hand() -> void:
	mesh_arr[selected_idx].material_overlay = null
	selected_idx += 1
	selected_idx = selected_idx%2
	mesh_arr[selected_idx].material_overlay = highlight
