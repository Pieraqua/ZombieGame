extends Node

signal damaged(damage_num, player : Player)

func damage(damage_num : int, player : Player):
	emit_signal('damaged', damage_num, player)
		
