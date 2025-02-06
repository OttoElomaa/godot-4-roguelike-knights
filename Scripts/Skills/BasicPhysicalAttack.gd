extends Node



var skill:Node = null
var actor:Node = null

@export var damage := 0
@export var attacksCount := 0

@export var isRanged := false


func setup(skill):
	self.skill = skill
	self.actor = skill.actor


#### RETURN TARGET=TRUE, RETURN NULL=FALSE
func activate(targets:Array) -> Node:
	
	#### NPC's GET TARGET FROM FILTERED LIST
	#### PLAYER HAS ITS OWN TARGETING SYSTEM
	var target = targets[0]
	if actor.isPlayer:
		target = actor.selectedTarget
	
	
	
	
	#### CREATE FIRST HALF OF DOUBLE MESSAGE
	skill.ui.saveInitialMessage(skill.actor.creatureName + " uses " + skill.skillName, Color.WHITE)
	var success = false
	
	for i in range(attacksCount):
		var newSuccess:bool = target.stats.handlePhysicalHit(damage)
		if newSuccess:
			success = true
	
	#### POST THE FIRST HALF IF LAST HALF FAILS
	#if not success:
		#skill.ui.clearInitialRow()
	
	if isRanged:
		skill.world.lineOfSight.createRangedLine(actor.position, target.position)
		
	return target
	
	
