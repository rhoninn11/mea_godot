extends Node2D

@onready var eyes: Area2D = $Matka/oczy
@onready var matka: Sprite2D = $Matka

enum States {
	GO_OBSERVING, 
	OBSERVING, 
	GO_TO_FIRE, 
	
}

@export var window_limit: float = 100


var m_state: States = States.GO_OBSERVING
func _ready() -> void:
	eyes.area_entered.connect(self.observe)

func _process(delta: float) -> void:
	const matka_speed: float = 50

	if m_state == States.GO_OBSERVING:
		var go_to = self.global_position.x + window_limit
		var new_pos = matka.global_position.x + delta * matka_speed
		matka.global_position.x = new_pos
		#print("+++ new pos is: ", new_pos)
		
		if new_pos >= go_to:
			m_state = States.OBSERVING

	

func observe(area: Node2D) -> void:
	print("+++ no to czekamy na rodzinkę:D")
	if area.is_in_group("vision"):
		print("+++ o jakiś vision się trafił:D")
	

func _on_okno_node_spoted(body: Node2D) -> void:
	print("check")
	var to_act = body.is_in_group("family_member")
	if to_act:
		print("okej już idzie pora, wstawiam ziemniaki")


	
