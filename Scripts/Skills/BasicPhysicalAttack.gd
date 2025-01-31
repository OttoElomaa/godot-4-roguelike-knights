extends Node



var skill:Node = null
var actor:Node = null

@export var damage := 0
@export var isRanged := false


func setup(skill):
	self.skill = skill
	self.actor = skill.actor


#### RETURN TARGET=TRUE, RETURN NULL=FALSE
func activate(targets:Array) -> Node:
	
	var target = targets[0]
	
	skill.ui.addMessage(skill.actor.creatureName + " uses " + skill.skillName, Color.WHITE)
	target.handlePhysicalHit(damage)
	
	if isRanged:
		skill.world.lineOfSight.createRangedLine(actor.position, target.position)
		
	return target
	
	
