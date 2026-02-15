extends Node

# El "motor" de red que usa Steam
var peer = SteamMultiplayerPeer.new()
var id_del_lobby_actual: int = 0

func _ready():
	Steam.steamInit(480)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.join_requested.connect(_on_lobby_join_requested)
	# Señal de Godot: Se activa en el CLIENTE cuando logra conectar con el HOST
	multiplayer.connected_to_server.connect(_on_conexion_exitosa)
	# Señal de Godot: Se activa si la conexión falla
	multiplayer.connection_failed.connect(_on_conexion_fallida)
	# Revisar si el juego se abrió mediante una invitación de Steam (importante)
	var args = OS.get_cmdline_args()
	if args.size() > 0:
		for arg in args:
			# Si el argumento es un número de lobby (+connect_lobby ID)
			if arg == "+connect_lobby":
				# El siguiente argumento sería el ID
				var index = args.find(arg)
				var lobby_invitado = args[index + 1].to_int()
				unirse_a_partida_por_id(lobby_invitado)

func _process(_delta):
	# Esto es vital para que Steam envíe las señales a Godot
	Steam.run_callbacks()
	
# --- LÓGICA DEL ANFITRIÓN (HOST) ---

func crear_partida_steam():
	# 1. Limpieza total de cualquier rastro previo
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	
	print("Limpieza de socket completada. Creando lobby...")
	id_del_lobby_actual = 0
	# Pedimos a Steam que cree la sala
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)

func _on_lobby_created(result: int, lobby_id: int):
	if result == 1:
		id_del_lobby_actual = lobby_id
	
	var fresh_peer = SteamMultiplayerPeer.new()
	# CAMBIO: Usamos 0, NO el lobby_id
	var error = fresh_peer.create_host(0) 
	
	if error == OK:
		peer = fresh_peer
		multiplayer.multiplayer_peer = peer
		# Opcional: Publicar el nombre para que otros lo vean
		Steam.setLobbyData(lobby_id, "name", "Partida de " + Steam.getPersonaName())
		print("Servidor iniciado correctamente en el lobby: ", lobby_id)
	else:
		print("Error al crear el socket (Puerto inválido): ", error)
# --- LÓGICA DE INVITACIONES ---

# Esto se activa cuando tu amigo te invita y tú aceptas desde el chat de Steam
func _on_lobby_join_requested(lobby_id: int, friend_id: int):
	print("Uniéndose a la partida de: ", Steam.getFriendPersonaName(friend_id))
	unirse_a_partida_por_id(lobby_id)

func unirse_a_partida_por_id(lobby_id: int):
	multiplayer.multiplayer_peer = null
	peer = SteamMultiplayerPeer.new()
	
	# 1. Obtenemos quién es el dueño (Host) de ese lobby
	var host_id = Steam.getLobbyOwner(lobby_id)
	
	print("Intentando conectar con el SteamID del Host: ", host_id)
	# 2. CAMBIO: Conectamos al host_id, puerto 0
	var error = peer.create_client(host_id, 0)
	
	if error == OK:
		multiplayer.multiplayer_peer = peer
	else:
		print("Error al intentar conectar: ", error)

# --- EXTRAS ÚTILES ---

func invitar_amigos():
	# Usamos nuestra variable guardada en lugar de pedírsela al peer
	if id_del_lobby_actual > 0:
		Steam.activateGameOverlayInviteDialog(id_del_lobby_actual)
	else:
		print("Error: No hay un ID de lobby guardado. ¿Ya hiciste Host?")

func _on_conexion_exitosa():
	print("¡Conectado al Host exitosamente!")
	# AQUÍ es donde mandamos al amigo al mundo automáticamente
	get_tree().change_scene_to_file("res://World.tscn")

func _on_conexion_fallida():
	print("No se pudo conectar con el amigo.")
