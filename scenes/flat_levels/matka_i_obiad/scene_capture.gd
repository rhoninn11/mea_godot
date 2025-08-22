extends Camera2D
class_name Camera2DDlaMatki

@onready var kurtyna: Sprite2D = $kurtyna_0

@export var initial_size: float = 20
@export var final_size: float = 1.3

var initial_zoom: float = 1
var clossing_zoom: float = 6

var initial_pos: Vector2 = Vector2(256,256)
var closing_pos: Vector2

var closing_timer: float = 0
var closing_time: float = 1

enum States {
	IDLE,
	I_CLOSING_STAGE,
	II_CLOSING_STAGE,
}
var m_state: States = States.IDLE

signal transition_ended()

func _process(delta: float) -> void:
	if (m_state == States.I_CLOSING_STAGE):
		closing_timer += delta
		closing_timer = min(closing_timer, closing_time)
		
		var progress: float = closing_timer/closing_time
		var cam_offset: Vector2 = lerp(initial_pos, closing_pos, progress)
		var cam_zoom: float = lerp(initial_zoom, clossing_zoom, progress)
		self.offset = cam_offset
		self.zoom = Vector2(cam_zoom, cam_zoom)
		
		var curtain_size: float = lerp(initial_size, final_size, progress)
		kurtyna.scale = Vector2(curtain_size, curtain_size)
			
		if closing_time == closing_timer:
			m_state = States.II_CLOSING_STAGE
			transition_ended.emit()
			

func start_closing(focus_pos: Vector2) -> void:
	closing_pos = focus_pos
	m_state = States.I_CLOSING_STAGE
	kurtyna.global_position = closing_pos
