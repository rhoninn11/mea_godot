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
@onready var plane_arr: Array[VerticalComponentInert] = [$pawn/right/plane_2d, $pawn/left/plane_2d];
@onready var active_arr: Array[bool] = [false, false]
@onready var poses_arr: Array[Vector2] = [Vector2(-1, 0.75), Vector2(1, 0.75)]

@onready var vert_pos: VerticalComponent = $pawn/VerticalComponent

@onready var plane_char: VerticalComponentInert = $pawn/plane_2d


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

	plane_char.lim_2d = Vector2(1000, 1)

func _process(delta: float) -> void:
	var spacja: = Input.is_action_pressed("mouse_capture")
	if spacja: 
		ControlContext.control_state = Enums.ControlState.POINTING
		speed_t.start()
	else:
		ControlContext.control_state = Enums.ControlState.TRAVEL

	

	active_arr[0] = Input.is_action_pressed("right_hand");
	active_arr[1] = Input.is_action_pressed("left_hand");

	plane_char.simulate(delta, !active_arr[0] && !active_arr[1]);

	update_speed()
	update_pos(delta)
	update_playback(delta)
	update_hand(delta)

	# if Input.is_action_just_pressed("tab"):
		# switch_hand()

func update_hand(delta: float) -> void:
	for i in range(len(hand_arr)):

		plane_arr[i].simulate(delta, active_arr[i]);
		var calc_pos = poses_arr[i] + plane_arr[i].fn_val();
		hand_arr[i].transform.origin = Vector3(-calc_pos.x, calc_pos.y, -1.3);

		if active_arr[i]:
			mesh_arr[i].material_overlay = highlight
		else:
			mesh_arr[i].material_overlay = null

func update_pos(delta: float) -> void:
	if not has_control:
		return
	
	var char_delta: = plane_char.fn_val().x;
	
	var xform := Transform3D.IDENTITY;
	var angle := char_delta + PI
	var m_forward := cos(angle) * Vector3.FORWARD + sin(angle) * Vector3.LEFT
	var m_left := cos(angle + PI*0.5) * Vector3.FORWARD + sin(angle + PI*0.5) * Vector3.LEFT
	UiManager.print("m_forward", str(m_forward))
	UiManager.print("m_left", str(m_left))

	xform.basis.z = m_forward;
	xform.basis.x = m_left;

	var move := Input.get_vector("up", "down", "left", "right")
	var move_3d := Vector3(move.y, 0, move.x)
	
	if move_3d != Vector3.ZERO:
		move_3d = move_3d*delta*var_speed
		var move_delta :=  xform * move_3d
		self.transform.origin += move_delta
	
	self.transform.basis = xform.basis

@export var speed_mult: float = 2;
func update_speed() -> void:
	speed_up_last = speed_up
	speed_up = speed_t.time_left > 0
	
	if speed_up:
		var_speed = speed * speed_mult;
	else:
		var_speed = speed;
		
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
