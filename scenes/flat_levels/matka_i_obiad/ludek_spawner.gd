extends Node2D

@export var ludki: Array[LudekData]
@export var ludekScene: PackedScene
@export var spawn_point: Vector2
@export var wait_point: Vector2
@export var limit: int = 3

enum SpawneStates {
	SPAWN,
	IDLE
}
var spawne_state: SpawneStates = SpawneStates.IDLE
var spawn_flag: bool
var spawn_time: float
var spawn_node: Ludek

var exluded: Array[int] = []
var fammily_wait: int = 0
var all_family_members: bool = false

func spawn_next() -> void:
	if spawne_state == SpawneStates.IDLE:
		spawne_state = SpawneStates.SPAWN
		spawn_time = 0
		spawn_flag = false

func _ready() -> void:
	spawn_next()

func sample() -> int:
	return randi() % len(ludki)

func select_next_ludek() -> LudekData:
	var idx: int
	while true:
		idx = sample()
		var ludek = ludki[idx]
		if ludek.is_family_member and fammily_wait == 0 and not exluded.has(idx):
			fammily_wait = limit
			exluded.append(idx)
			break
		if not ludek.is_family_member:
			if fammily_wait > 0 and not all_family_members:
				fammily_wait -= 1
				break
			if all_family_members:
				break

	if len(exluded) == 2:
		all_family_members = true
	var tmp = ludki[idx]
	return tmp

func _process(delta: float) -> void:
	if spawne_state == SpawneStates.SPAWN:
		if not spawn_flag:
			spawn_flag = true
			spawn_node = ludekScene.instantiate() as Ludek
			
			spawn_node.config(self.select_next_ludek())
			spawn_node.left_screan.connect(self.spawn_next)
			self.get_parent().add_child(spawn_node)
			
		spawn_time += delta
		spawn_time = min(spawn_time, 1)
		var dst_pos =  lerp(spawn_point, wait_point, spawn_time)
		spawn_node.position = dst_pos
		if spawn_time == 1:
			spawn_node.you_are_capitan_now()
			spawne_state = SpawneStates.IDLE
