extends Node3D

@onready var spawn_parent = $SpawnParent
var player_scene = preload("res://Player.tscn")

func _ready():
	# Esperamos un frame para asegurar que el NetworkManager ya asignó el peer
	await get_tree().process_frame
	
	if multiplayer.multiplayer_peer == null:
		print("Error: El peer no llegó a tiempo al mundo")
		return

	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		add_player(1)

# Esta función la corre SOLO el servidor
func _on_peer_connected(id):
	print("Se ha unido un amigo con ID: ", id)
	# Un pequeño delay ayuda a que el peer de Steam termine de negociar el P2P
	await get_tree().create_timer(0.5).timeout
	add_player(id)

func add_player(id):
	# Evitar duplicados (por si acaso la señal se dispara dos veces)
	if spawn_parent.has_node(str(id)):
		return
		
	var player = player_scene.instantiate()
	player.name = str(id) # Vital para MultiplayerSynchronizer
	spawn_parent.add_child(player, true) # true permite que el nombre sea exacto
	print("Jugador instanciado para ID: ", id)

# Si un amigo se va, limpiamos su personaje
func _on_peer_disconnected(id):
	if spawn_parent.has_node(str(id)):
		spawn_parent.get_node(str(id)).queue_free()