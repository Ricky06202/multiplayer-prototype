extends CanvasLayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		visible = !visible

func _on_invitar_pressed() -> void:
	# 1. Le pedimos al Singleton que invite a amigos
	NetworkManager.invitar_amigos()
