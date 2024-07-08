extends Node

signal damaged(damage_num)

func damage(damage_num : int):
	emit_signal('damaged', damage_num)
		
