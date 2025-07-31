extends Sprite2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("check")
	var to_act = body.is_in_group("family_member")
	if to_act:
		print("okej już idzie pora, wstawiam ziemniaki")
