extends Node

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene = preload("res://Player.tscn")
var port = 1027

func _ready():
	multiplayer.connected_to_server.connect(_on_connection_success)

func _on_connection_success():
	# El cliente se cambia a sí mismo de escena manualmente
	get_tree().change_scene_to_file("res://World.tscn")

func host_game():
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	# Al hacer esto siendo el servidor, Godot le dirá a 
	# todos los que se conecten: "Oigan, cámbiense a esta escena"
	get_tree().change_scene_to_file("res://World.tscn")

func join_game(address):
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	# AQUÍ NO CAMBIAMOS LA ESCENA. 
	# Esperamos a que el servidor nos arrastre.

func _on_player_connected(id):
	print("Jugador conectado con ID: ", id)
	# Aquí es donde el MultiplayerSpawner del mundo entrará en acción
