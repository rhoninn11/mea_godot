extends Control

@onready var text: = $"ColorRect/Label"

func _process(delta: float) -> void:
	var dbg_msgs: = UiManager.debug_map;

	var m_str: = ""
	for k in dbg_msgs:
		m_str += "K: %20s | %s\n" % [k, dbg_msgs[k]]
	
	text.text = m_str
