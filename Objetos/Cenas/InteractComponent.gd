extends Node

#@export var interact_name : String
var interact_string : String

func _ready():
	%InteractArea.connect('body_entered', player_in_range)
	%InteractArea.connect('body_exited', player_outof_range)

func interact(player : Player):
	get_parent().interact(player)

func player_in_range(body : Node3D):
	if "players" in body.get_groups():
		body.interactable_in_range(self, interact_string)
		pass

func player_outof_range(body : Node3D):
	body.interactable_outof_range(self)
	pass
