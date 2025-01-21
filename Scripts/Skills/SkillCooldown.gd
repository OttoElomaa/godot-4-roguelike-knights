extends Node


@export var cooldown := 0
var currentCooldown := 0



func tickCooldown() -> int:
	
	if currentCooldown > 0:
		currentCooldown -= 1
		
	return currentCooldown


func putOnCooldown() -> int:
	currentCooldown = cooldown + 1
	return currentCooldown
		
		
func isOnCooldown():
	
	if currentCooldown > 0:
		return true
	return false
