extends Node



var skill:Node = null


func setup(skill):
	self.skill = skill


#### SUCCESS=TRUE, FAILURE=FALSE
func activate(target:Node) -> bool:
	
	skill.ui.addMessage(skill.actor.creatureName + " uses " + skill.skillName, Color.WHITE)
	target.takeDamage(20)
	return true
	
	
