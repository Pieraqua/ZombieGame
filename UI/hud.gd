extends Control

@onready var points_label = %Points

func _ready():
	%InteractablesContainer.visible = false
	%RoundLabelBox/DisplayTimer.timeout.connect(hide_round_label)

func update_points(player : Player):
	points_label.text = 'Points: %d' % player.points

func update_crosshair(_spread : float):
	pass

func update_interactables(active_interactables_len : int, interact_string : String):
	if active_interactables_len > 0:
		%InteractablesContainer.visible = true
		if interact_string != '':
			%InteractablesContainer/InteractablesLabel.text = interact_string
		else:
			%InteractablesContainer/InteractablesLabel.text = 'no interact string configured'
	else:
		%InteractablesContainer.visible = false

func show_round_label(current_round : int):
	%RoundLabelBox/DisplayTimer.start()
	%RoundLabelBox.visible = true
	%RoundLabelBox/RoundText.text = 'Round %d' % current_round
	
func hide_round_label():
	%RoundLabelBox.visible = false
	
