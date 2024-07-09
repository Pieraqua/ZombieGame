extends Node

@onready var player = $Player

var points : int = 500

func _ready():
	connect('points_update', $HUD.update_points)

func _physics_process(delta):
	get_tree().call_group('enemies', 'update_target_location', player.global_transform.origin)

signal points_update(points:int)
func update_points(point_amount : int):
	points += point_amount
	emit_signal('points_update', points)
