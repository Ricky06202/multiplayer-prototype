extends Node3D

@onready var spawn_parent = $SpawnParent
var player_scene = preload("res://Player.tscn")

func _ready():
	if multiplayer.is_server():
		add_player(1) # Spawnea al Host
	else:
		# El cliente le avisa al servidor: "Ya terminé de cargar el mapa"
		tell_server_i_am_ready.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func tell_server_i_am_ready():
	var id = multiplayer.get_remote_sender_id()
	add_player(id) # Ahora el Host spawnea al cliente con seguridad

func add_player(id):
	var player = player_scene.instantiate()
	player.name = str(id) # IMPORTANTE: El nombre del nodo debe ser el ID
	spawn_parent.add_child(player)

func _on_peer_connected(id):
	# Le damos un respiro al cliente para que cargue la escena
	await get_tree().create_timer(0.2).timeout 
	add_player(id)
