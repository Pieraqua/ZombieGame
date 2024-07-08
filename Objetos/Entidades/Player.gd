extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var sensitivity : float = 0.001

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D

@export_subgroup("Armas")
@export var weapons : Array[Weapon] = []
var weapon : Weapon
var weapon_index := 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var camera_limit : float = PI/2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weapon = weapons[weapon_index]
	swap_weapon()
	
	
	
func _input(event):
	if event is InputEventMouseMotion:
		transform.basis = transform.basis.rotated(Vector3.UP, event.relative.x * -sensitivity)
		camera.rotate_x(event.relative.y * -sensitivity)
		if camera.rotation.x > camera_limit:
			camera.rotation.x = camera_limit
		elif camera.rotation.x < -camera_limit:
			camera.rotation.x = -camera_limit
		
	elif event is InputEventKey:
		if event.is_action_pressed('SensePlus'):
			sensitivity += 0.001
		elif event.is_action_pressed('SenseMinus'):
			sensitivity -= 0.001
		elif event.is_action_pressed('ExitGame'):
			get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
			get_tree().quit()
		elif event.is_action_pressed('EscapeMouse'):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventMouseButton:
		if event.is_action_pressed('Shoot'):
			if !raycast.is_colliding(): return
			
			var target = raycast.get_collider() # A CollisionObject3D.
			var shape_id = raycast.get_collider_shape() # The shape index in the collider.
			
			if target and not target is CSGCombiner3D:
				var owner_id = target.shape_find_owner(shape_id) # The owner ID in the collider.
				var shape = target.shape_owner_get_owner(owner_id)
				var dmg_component = shape.find_child("DamageableComponent")
				if dmg_component:
					dmg_component.damage(weapon.damage)
				
			var impact = preload("res://Objetos/Impacto/Impacto.tscn")
			var impact_instance = impact.instantiate()
			
			get_tree().root.add_child(impact_instance)
			impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
			impact_instance.emitting = true
			
			

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func swap_weapon():
	raycast.target_position = Vector3(0, -weapon.max_distance, 0)
