extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var raycast = $RayCast3D
@onready var animation_player = $AnimationPlayer

@export_category("Attributes")
@export var SPEED = 3.0
@export var HP = 90

@export_category("Weapon")
@export var DAMAGE = 30.0
@export var RANGE = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var attacking = false

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()
		return
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	velocity.x = (next_location - current_location).normalized().x * SPEED
	velocity.z = (next_location - current_location).normalized().z * SPEED
	
	var target_vector = global_position.direction_to(next_location)
	var target_basis = Basis.looking_at(target_vector)
	basis = basis.slerp(target_basis, 0.1)
	move_and_slide()
	
	if not attacking and raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and "players" in collider.get_groups():
			print("player aimed at")
			animation_player.play("attack_zombie")
			attacking = true

func finish_attack(anim):
	if anim == 'attack_zombie':
		attacking = false
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			print("zombie hit")
			if "players" in collider.get_groups():
				print("player hit")
		
func update_target_location(target_location):
	nav_agent.set_target_position(target_location)
	
func headshot_damage(damage_num : int):
	HP -= damage_num * 2
	print('headshot damage')
	if HP <= 0:
		die()
		
func body_damage(damage_num : int):
	HP -= damage_num
	print('body damage')
	if HP <= 0:
		die()

func die():
	queue_free()
