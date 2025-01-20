extends Node



var skill:Node = null
var actor:Node = null

@export var damage := 0
@export var isRanged := false


func setup(skill):
	self.skill = skill
	self.actor = skill.actor


#### SUCCESS=TRUE, FAILURE=FALSE
func activate(targets:Array) -> bool:
	
	var target = targets[0]
	
	skill.ui.addMessage(skill.actor.creatureName + " uses " + skill.skillName, Color.WHITE)
	target.takeDamage(damage)
	
	if isRanged:
		skill.world.lineOfSight.createRangedLine(actor.position, target.position)
		
	return true
	
	
