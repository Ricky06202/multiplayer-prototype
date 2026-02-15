extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready():
	# Establecemos quién manda sobre este nodo
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		$Camera3D.make_current() # Fuerza a que ESTA sea la cámara activa
	else:
		$Camera3D.current = false # Opcional: apágala si no es tuya
	
	# Si NO tengo autoridad, apago la cámara y el procesamiento
	if not is_multiplayer_authority():
		$Camera3D.current = false
		set_process(false)
		set_physics_process(false)

func _physics_process(delta):
	# Este código solo se ejecutará en la PC del dueño del personaje
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# if Input.is_action_just_pressed("jump") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _on_tree_entered() -> void:
	set_multiplayer_authority(name.to_int())
