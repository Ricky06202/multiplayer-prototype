extends Control

@onready var ip_input = $HBoxContainer/IPAddress

func _on_host_pressed() -> void:
	# Llamamos al Singleton para que cree el servidor
	NetworkManager.host_game()
	# El Singleton se encargará de cambiar la escena a "World.tscn"
	hide()

func _on_join_pressed() -> void:
	var address = ip_input.text
	if address.is_empty():
		address = "127.0.0.1"
	
	NetworkManager.join_game(address)
	hide()
