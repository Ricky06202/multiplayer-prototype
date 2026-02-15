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
	# 1. Cerramos el peer actual de forma segura si existe
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	
	multiplayer.multiplayer_peer = null
	peer = SteamMultiplayerPeer.new() 
	
	print("Limpieza de socket completada. Creando lobby...")
	id_del_lobby_actual = 0
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)

func _on_lobby_created(result: int, lobby_id: int):
	if result == 1:
		id_del_lobby_actual = lobby_id
		var error = peer.create_host(lobby_id)
		if error == OK:
			multiplayer.multiplayer_peer = peer
			print("Lobby creado y Guardado: ", id_del_lobby_actual)
		else:
			# Esto te dirá exactamente qué código de error da Godot
			print("Error crítico al crear Host: ", error) 
	else:
		print("Steam no pudo crear el lobby. Resultado: ", result)
# --- LÓGICA DE INVITACIONES ---

# Esto se activa cuando tu amigo te invita y tú aceptas desde el chat de Steam
func _on_lobby_join_requested(lobby_id: int, friend_id: int):
	print("Uniéndose a la partida de: ", Steam.getFriendPersonaName(friend_id))
	unirse_a_partida_por_id(lobby_id)

func unirse_a_partida_por_id(lobby_id: int):
	# 1. Limpiamos antes de intentar unirnos
	multiplayer.multiplayer_peer = null
	peer = SteamMultiplayerPeer.new()
	
	print("Intentando unir al lobby: ", lobby_id)
	var error = peer.create_client(lobby_id) 
	if error == OK:
		multiplayer.multiplayer_peer = peer
	else:
		print("Error al unirse: ", error)

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