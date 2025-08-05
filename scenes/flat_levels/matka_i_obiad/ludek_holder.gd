extends CharacterBody2D
class_name LudekHolder

var hover: bool = false

signal hold_start_sig(node: Node2D)
signal hold_end_sig()

func hold_start(node: Node2D) -> void:
	hold_start_sig.emit(node)

func hold_end() -> void:
	hold_end_sig.emit()
