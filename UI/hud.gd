extends Control

@onready var points_label = $PanelContainer/Points

func update_points(points : int):
	points_label.text = 'Points: %d' % points

func update_crosshair(_spread : float):
	pass
