extends Node

var peer = SteamMultiplayerPeer.new()
var id_del_lobby_actual: int = 0

func _ready():
	Steam.steamInit(480)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.join_requested.connect(_on_lobby_join_requested)
	
	multiplayer.connected_to_server.connect(_on_conexion_exitosa)
	multiplayer.connection_failed.connect(_on_conexion_fallida)

	var args = OS.get_cmdline_args()
	if args.size() > 0:
		for arg in args:
			if arg == "+connect_lobby":
				var index = args.find(arg)
				var lobby_invitado = args[index + 1].to_int()
				unirse_a_partida(lobby_invitado)

func _process(_delta):
	Steam.run_callbacks()

# --- LÓGICA DEL ANFITRIÓN ---

func crear_partida_steam():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	
	print("Iniciando creación de lobby...")
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)

func _on_lobby_created(result: int, lobby_id: int):
	if result == 1:
		id_del_lobby_actual = lobby_id
		
		# IMPORTANTE: Todo esto debe ir DENTRO del 'if result == 1'
		var fresh_peer = SteamMultiplayerPeer.new()
		var error = fresh_peer.create_host(0) # Puerto 0 para Steam P2P
		
		if error == OK:
			peer = fresh_peer
			multiplayer.multiplayer_peer = peer
			Steam.setLobbyData(lobby_id, "name", "Partida de " + Steam.getPersonaName())
			print("Servidor iniciado. Lobby ID: ", id_del_lobby_actual)
		else:
			print("Error al crear host: ", error)
	else:
		print("Fallo al crear lobby en Steam.")

# --- LÓGICA DE UNIRSE ---

# Cuando aceptas invitación, Steam te da el lobby Y el ID de tu amigo (friend_id)
func _on_lobby_join_requested(lobby_id: int, friend_id: int):
	print("Invitación aceptada de: ", Steam.getFriendPersonaName(friend_id))
	unirse_a_partida(lobby_id, friend_id)

func unirse_a_partida(lobby_id: int, host_id: int = 0):
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	
	peer = SteamMultiplayerPeer.new()
	
	# Si no conocemos el host_id, se lo pedimos al lobby
	if host_id == 0:
		host_id = Steam.getLobbyOwner(lobby_id)
	
	# Si sigue siendo 0, es que Steam aún no sabe quién es el dueño
	if host_id == 0:
		print("Error: El Host ID sigue siendo 0. Reintentando...")
		return

	print("Conectando al Host SteamID: ", host_id)
	var error = peer.create_client(host_id, 0)
	
	if error == OK:
		multiplayer.multiplayer_peer = peer
	else:
		print("Fallo al crear cliente: ", error)

# --- EXTRAS ---

func invitar_amigos():
	if id_del_lobby_actual > 0:
		Steam.activateGameOverlayInviteDialog(id_del_lobby_actual)

func _on_conexion_exitosa():
	print("¡Conexión total establecida!")
	get_tree().change_scene_to_file("res://World.tscn")

func _on_conexion_fallida():
	print("La conexión de red de Godot falló.")
