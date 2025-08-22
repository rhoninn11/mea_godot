extends Node2D

@onready var eyes: Area2D = $Matka/oczy
@onready var matka: Sprite2D = $Matka
@onready var arms: Area2D = $Matka/ramiona
@onready var smile: Sprite2D = $Smilet
enum States {
	GO_OBSERVING, 
	OBSERVING, 
	GO_TO_OVEN,
	ALL_HOME,
	SMILE,
	GO_TO_FAMILY,
}

@export var mom_speed: float = 50
@export var window_limit: float = 100
@export var oven_limit: float = -100
@export var wait_Limit: float = 10
@export var scene_capture: Camera2DDlaMatki

var total_family_member: int = 2
var count_family_member: int = 0
var family_member_spoted: bool = false
var garnek_level: int = 0

var smile_timer : float = 0
@export var smile_time: float = 1

var m_state: States = States.ALL_HOME

func do_smile() -> void:
	print("+++ smile")
	m_state = States.SMILE

func _ready() -> void:
	eyes.area_entered.connect(self.eyes_detect)
	arms.area_entered.connect(self.arms_interaction)
	
	scene_capture.transition_ended.connect(self.do_smile)

func _process(delta: float) -> void:
	if m_state == States.GO_OBSERVING:
		matka.scale = Vector2(1,1)
		var go_to = self.global_position.x + window_limit
		var new_pos = matka.global_position.x + delta * mom_speed
		matka.global_position.x = new_pos
		#print("+++ new pos is: ", new_pos)
		
		if new_pos >= go_to:
			m_state = States.OBSERVING
			family_member_spoted = false
	
	if m_state == States.OBSERVING:
		if family_member_spoted:
			m_state = States.GO_TO_OVEN
			count_family_member += 1
			print("+++ O! już idzie pora podgrzać zupę")
			
	if m_state == States.GO_TO_OVEN:
		matka.scale = Vector2(-1,1)
		var go_to = self.global_position.x + oven_limit
		var new_pos = matka.global_position.x - delta * mom_speed * 1.5
		if new_pos > go_to:
			matka.global_position.x = new_pos
		else:
			print("+++ garnek level: ", garnek_level, " family members: ", count_family_member)
			if garnek_level == count_family_member:
				if count_family_member == total_family_member:
					m_state = States.ALL_HOME
				else:
					m_state = States.GO_OBSERVING
	
	if m_state == States.ALL_HOME:
		matka.scale = Vector2(1,1)
		var go_to = self.global_position.x + wait_Limit
		var new_pos = matka.global_position.x + delta * mom_speed * 0.5
		if new_pos < go_to:
			matka.global_position.x = new_pos
		else:
			if scene_capture:
				scene_capture.start_closing(eyes.global_position)
					
	if m_state == States.SMILE:
		smile.visible = true
		smile_timer += delta
		
		if smile_timer > smile_time:
			m_state = States.GO_TO_FAMILY
		
	
func eyes_detect(area: Node2D) -> void:
	print("+++ Eyes area contacted with other area")


func on_vision(body: Node2D) -> void:
	print("+++ nowy ludek spoted")
	if body.is_in_group("family_member"):
		family_member_spoted = true
		
func arms_interaction(node: Node2D) -> void:
	if node.is_in_group("interact"):
		var main_node = node.get_main_node()
		main_node.start_boiling()
		garnek_level += 1
		
