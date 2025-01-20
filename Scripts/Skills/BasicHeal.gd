extends Node




var skill:Node = null


func setup(skill):
	self.skill = skill


#### SUCCESS=TRUE, FAILURE=FALSE
func activate(targets:Array) -> bool:
	
	var target = sortByLowestHealth(targets)
	
	#if target.getHealth() >= target.maxHealth:
		#return false
	
	skill.ui.addMessage(skill.actor.creatureName + " uses " + skill.skillName, Color.WHITE)
	target.recoverHealth(15)
	return true


func sortByLowestHealth(targets:Array) -> Node:
	
	var lowestNum := 10000
	var lowest:Node = null
	
	for t in targets:
		if t.getHealth() < lowestNum:
			lowestNum = t.getHealth()
			lowest = t
			
	return lowest
