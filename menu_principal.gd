extends Control

func _on_host_pressed() -> void:
	# 1. Le pedimos al Singleton que empiece a crear el lobby de Steam de fondo
	NetworkManager.crear_partida_steam()
	
	# 2. Cambiamos de escena inmediatamente al mundo
	# Así el Host ya puede empezar a caminar mientras Steam termina de conectar
	get_tree().change_scene_to_file("res://World.tscn")

func _on_join_pressed() -> void:
	# Si vas a usar el sistema de invitaciones de Steam, 
	# técnicamente no necesitas un botón de "Join" en el menú, 
	# porque Steam abre el juego solo cuando aceptas la invitación.
	# Pero puedes dejarlo para abrir la lista de amigos:
	Steam.activateGameOverlay("friends")
