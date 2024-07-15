extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var sensitivity : float = 0.001
var points : int = 500

@onready var camera = $Camera3D
@onready var subviewport_camera = %SubviewportCamera
@onready var raycast = $Camera3D/RayCast3D

@export_subgroup("Armas")
@export var weapons : Array[Weapon] = []
var weapon : Weapon
var weapon_index := 0
var shooting = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var camera_limit : float = PI/2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weapon = weapons[weapon_index]
	swap_weapon()
	
func _input(event):
	# Key events
	if event is InputEventKey:
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
		elif event.is_action_pressed('Interact'):
			# Interact with item currently highlighted
			if len(active_interactables) > 0:
				active_interactables[current_interactable].node.interact(self)
			pass
		elif event.is_action_pressed('SwapWeapons'):
			weapon_index += 1
			if weapon_index >= len(weapons):
				weapon_index = 0
			swap_weapon()
				
	# Mouse events
	elif event is InputEventMouseButton:
		if event.is_action_pressed('Shoot'):
			shoot()
			
	elif event is InputEventMouseMotion:
		transform.basis = transform.basis.rotated(Vector3.UP, event.relative.x * -sensitivity)
		camera.rotate_x(event.relative.y * -sensitivity)
		if camera.rotation.x > camera_limit:
			camera.rotation.x = camera_limit
		elif camera.rotation.x < -camera_limit:
			camera.rotation.x = -camera_limit
			

@onready var weapon_timer = $WeaponTimer
func shoot():
	if not weapon_timer.is_stopped():
		return
		
	weapon_timer.start(weapon.cooldown)
	
	if !raycast.is_colliding(): 
		return
		
	var target = raycast.get_collider() # A CollisionObject3D.
	var shape_id = raycast.get_collider_shape() # The shape index in the collider.
	
	if target and not target is CSGCombiner3D:
		var owner_id = target.shape_find_owner(shape_id) # The owner ID in the collider.
		var shape = target.shape_owner_get_owner(owner_id)
		var dmg_component = shape.find_child("DamageableComponent")
		if dmg_component:
			dmg_component.damage(weapon.damage, self)
		
	var impact = preload("res://Objetos/Impacto/Impacto.tscn")
	var impact_instance = impact.instantiate()
	
	get_tree().root.add_child(impact_instance)
	impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
	impact_instance.emitting = true

func weapon_timer_callback():
	if weapon.automatic and Input.is_action_pressed("Shoot"):
		shoot()

func handle_movement(delta):
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

func handle_camera():
	subviewport_camera.set_global_transform(camera.get_global_transform())

func _physics_process(delta):
	handle_movement(delta)

func _process(_delta):
	handle_camera()

func swap_weapon():
	weapon = weapons[weapon_index]
	raycast.target_position = Vector3(0, -weapon.max_distance, 0)
	%WeaponMesh.set_mesh(weapon.model)

# Interactable handling
var active_interactables : Array = []
var current_interactable : int = 0

signal update_ui_interactables(active_interactables_len : int, interact_string : String)

func interactable_in_range(interactable : Node, interactable_string : String):
	var interact : Interactable = Interactable.new()
	interact.node = interactable
	interact.interact_string = interactable_string
	active_interactables.append(interact)
	# update ui
	emit_signal('update_ui_interactables', len(active_interactables), active_interactables[current_interactable].interact_string)

func interactable_outof_range(interactable : Node):
	var i = 0
	for interact in active_interactables:
		if interact.node == interactable:
			break
		i += 1
	active_interactables.remove_at(i)
	# update ui
	current_interactable = 0
	if len(active_interactables) > 0:
		emit_signal('update_ui_interactables', len(active_interactables),  active_interactables[current_interactable].interact_string)
	else:
		emit_signal('update_ui_interactables', len(active_interactables), '')
