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
	
	#### CREATE FIRST HALF OF DOUBLE MESSAGE
	skill.ui.saveInitialMessage(skill.actor.creatureName + " uses " + skill.skillName, Color.WHITE)
	var success = target.handlePhysicalHit(damage)
	
	#### POST THE FIRST HALF IF LAST HALF FAILS
	#if not success:
		#skill.ui.clearInitialRow()
	
	if isRanged:
		skill.world.lineOfSight.createRangedLine(actor.position, target.position)
		
	return target
	
	
