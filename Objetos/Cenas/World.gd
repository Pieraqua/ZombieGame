extends Node

@onready var closest_player = $Player

func _ready():
	connect('points_update', %HUD.update_points)
	connect('update_interactable_hud', %HUD.update_interactables)
	closest_player.connect('update_ui_interactables',update_interactable)
	update_points(0, closest_player)
func _physics_process(_delta):
	get_tree().call_group('enemies', 'update_target_location', closest_player.global_transform.origin)

signal points_update(player : CharacterBody3D)
func update_points(point_amount : int, player : Player):
	player.points += point_amount
	emit_signal('points_update', player)

func buy_weapon(weapon : Weapon, cost : int, player : CharacterBody3D):
	if player.points > cost:
		print('weapon bought : %s' % weapon.name)
		player.weapons.append(weapon)
		update_points(-cost, player)

signal update_interactable_hud(active_interactables_len : int, interact_string : String)
func update_interactable(active_interactables_len : int, interact_string : String):
	emit_signal('update_interactable_hud', active_interactables_len, interact_string)
