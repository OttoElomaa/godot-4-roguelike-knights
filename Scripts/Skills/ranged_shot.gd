extends Node


var skill:Node = null
var world:Node = null

func setup(skill):
	self.skill = skill
	self.world = skill.world
	
	

#### SUCCESS=TRUE, FAILURE=FALSE
func activate(target:Node) -> bool:
	
	var isTargetVisible: bool = world.lineOfSight.lineOfSightBetweenObjects(skill.actor, target)
	
	if isTargetVisible:
	
		skill.ui.addMessage(skill.actor.creatureName + " uses " + skill.skillName, Color.WHITE)
		target.takeDamage(20)
		return true
		
	return false
