extends Node


@export var healAmount := 0

var skill:Node = null



func setup(skill):
	self.skill = skill


#### SUCCESS=TRUE, FAILURE=FALSE
func activate(targets:Array) -> bool:
	
	var target = sortByLowestHealth(targets)
	
	#if target.getHealth() >= target.maxHealth:
	if target.hasFullHealth():
		return false
	
	skill.ui.addMessage(skill.actor.creatureName + " uses " + skill.skillName, Color.WHITE)
	target.recoverHealth(healAmount)
	
	skill.world.lineOfSight.createRangedLine(skill.actor.position, target.position)
	
	return true


func sortByLowestHealth(targets:Array) -> Node:
	
	var lowestNum := 10000
	var lowest:Node = targets[0]
	
	for t in targets:
		if t.getHealth() < lowestNum:
			if not t.hasFullHealth():
				lowestNum = t.getHealth()
				lowest = t
			
	return lowest
