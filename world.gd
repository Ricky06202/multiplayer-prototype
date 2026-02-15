extends Node3D

@onready var spawn_parent = $SpawnParent
var player_scene = preload("res://Player.tscn")

func _ready():
	# Solo el Host (servidor) tiene el poder de instanciar nodos que se sincronizan
	if multiplayer.is_server():
		# Conectamos la señal para detectar nuevos amigos
		multiplayer.peer_connected.connect(_on_peer_connected)
		# Nos spawneamos a nosotros mismos (el Host siempre es ID 1)
		add_player(1)
	else:
		# Si soy cliente, opcionalmente puedo avisar que ya cargué,
		# pero con MultiplayerSpawner, el servidor suele mandar el mando.
		pass

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