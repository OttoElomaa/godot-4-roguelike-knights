extends Node


@export var mustStandStill := false


#### MANAGE RESTRICTIONS THAT STATUS / BOON EFFECTS CAN HAVE
func checkRestrictions(creature:Node) -> bool:
	
	#### SOME ONLY TRIGGER, If creature stands still
	if mustStandStill:
		if not creature.isStationary:
			return false
			
	return true
