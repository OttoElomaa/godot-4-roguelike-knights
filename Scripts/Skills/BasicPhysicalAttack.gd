extends Node



var skill:Node = null


func setup(skill):
	self.skill = skill


#### SUCCESS=TRUE, FAILURE=FALSE
func activate(targets:Array) -> bool:
	
	skill.ui.addMessage(skill.actor.creatureName + " uses " + skill.skillName, Color.WHITE)
	targets[0].takeDamage(20)
	return true
	
	
