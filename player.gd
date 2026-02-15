extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003 # Ajusta esto a tu gusto

@onready var camera = $Camera3D

func _ready():
	# 1. Establecer autoridad primero usando el nombre del nodo (que será el ID de Steam)
	set_multiplayer_authority(name.to_int())
	
	if is_multiplayer_authority():
		# 2. Capturar el mouse
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.make_current()
		$LabelNombre.text = Steam.getPersonaName()
	else:
		# 3. Si no es nuestro, apagamos todo lo que no debemos tocar
		camera.current = false
		set_process(false)
		set_physics_process(false)
		# Opcional: podrías poner el nombre del dueño del otro personaje
		# $LabelNombre.text = "Jugador Remoto" 

func _input(event):
	if is_multiplayer_authority():
		# --- NUEVO: Solo procesar si el mouse está capturado ---
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				# Rotar el cuerpo (Eje Y)
				rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
				# Rotar la cámara (Eje X)
				camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
		# Control de escape para liberar/capturar el mouse
		if event.is_action_pressed("ui_cancel"):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# (Tu código de movimiento se queda igual, pero ahora usa la rotación del cuerpo)
	var input_dir = Input.get_vector("izquierda", "derecha", "adelante", "atras")
	
	# IMPORTANTE: Ahora el movimiento es relativo a hacia dónde mira el personaje
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()