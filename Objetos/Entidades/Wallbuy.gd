extends Sprite3D

@export var weapon : Weapon
@export var cost : int
@onready var interact_string = 'F: Buy %s (Cost: %d)' % [weapon.name, cost]

signal buy_weapon_signal(weapon : Weapon, cost : int, player : Player)

func _ready():
	buy_weapon_signal.connect(get_tree().root.get_child(0).buy_weapon)
	$InteractComponent.interact_string = interact_string

func interact(player : Player):
	emit_signal('buy_weapon_signal', weapon, cost, player)
