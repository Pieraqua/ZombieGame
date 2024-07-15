extends Resource
class_name Weapon

@export_subgroup("Propriedades")
@export_range(0.01,1) var cooldown : float = 0.2
@export_range(1,20) var max_distance : int = 15
@export_range(0,100) var damage : float = 30
@export var automatic : bool = false
@export var model : Mesh = load("res://Materiais/Modelos/ray_gun_low_poli.tres")
@export var name : String = "default_name"
