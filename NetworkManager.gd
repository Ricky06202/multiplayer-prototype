extends Node

# El "motor" de red que usa Steam
var peer = SteamMultiplayerPeer.new()
var id_del_lobby_actual: int = 0

func _ready():
	Steam.steamInit(480)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.join_requested.connect(_on_lobby_join_requested)

func _process(_delta):
	# Esto es vital para que Steam envíe las señales a Godot
	Steam.run_callbacks()
	
# --- LÓGICA DEL ANFITRIÓN (HOST) ---

func crear_partida_steam():
	print("Creando lobby en Steam...")
	# Creamos el lobby (Tipo Amigos, Max 4 personas)
	id_del_lobby_actual = 0
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4)

func _on_lobby_created(result: int, lobby_id: int):
	if result == 1:
		id_del_lobby_actual = lobby_id # <--- Aquí se guarda
		var error = peer.create_host(lobby_id)
		if error == OK:
			multiplayer.multiplayer_peer = peer
			print("Lobby creado y Guardado: ", id_del_lobby_actual)
# --- LÓGICA DE INVITACIONES ---

# Esto se activa cuando tu amigo te invita y tú aceptas desde el chat de Steam
func _on_lobby_join_requested(lobby_id: int, friend_id: int):
	print("Uniéndose a la partida de: ", Steam.getFriendPersonaName(friend_id))
	unirse_a_partida_por_id(lobby_id)

func unirse_a_partida_por_id(lobby_id: int):
	# Ya no usamos IPs, usamos el ID del Lobby o del Usuario
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