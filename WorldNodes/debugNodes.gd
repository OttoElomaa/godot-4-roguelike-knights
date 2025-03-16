extends Node2D





func _on_debug_timer_timeout() -> void:
	
	var world = get_parent()
	world.callNextTurnAction(world.player)
