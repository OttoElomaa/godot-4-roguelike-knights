extends Node


@export var healAmount := 0

var skill:Node = null



func setup(skill):
	self.skill = skill


#### RETURN TARGET=TRUE, RETURN NULL=FALSE
func activate(targets:Array) -> Node:
	
	var target = sortByLowestHealth(targets)
	
	#if target.getHealth() >= target.maxHealth:
	if target.hasFullHealth():
		return null
	
	skill.ui.addMessage(skill.actor.creatureName + " uses " + skill.skillName, Color.WHITE)
	target.recoverHealth(healAmount)
	
	skill.world.lineOfSight.createRangedLine(skill.actor.position, target.position)
	
	return target



func sortByLowestHealth(targets:Array) -> Node:
	
	var lowestNum := 10000
	var lowest:Node = targets[0]
	
	for t in targets:
		if t.getHealth() < lowestNum:
			if not t.hasFullHealth():
				lowestNum = t.getHealth()
				lowest = t
			
	return lowest
