extends Node



var skill:Node = null


func setup(skill):
	self.skill = skill


# Called when the node enters the scene tree for the first time.
func activate(target:Node):
	
	skill.ui.addMessage(skill.actor.creatureName + " uses " + skill.skillName)
	target.takeDamage(20)
	
	
