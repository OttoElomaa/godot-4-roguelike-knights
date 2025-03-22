extends Node


enum targetingGroupEnum {
	SELF, ENEMY, ALL_ENEMIES, ALLY, ALL_ALLIES
}	
@export var targetingGroup:targetingGroupEnum = targetingGroupEnum.ENEMY


var skill:Node = null
var actor:Node = null
var world:Node = null
var ui:Node = null



func setup(skill:Node):
	
	self.skill = skill
	self.actor = skill.actor
	self.world = actor.world
	self.ui = world.ui
	
	

func handleTargeting():

	var targets:Array = getTargetGroup()
	
	var targetsInRange := []
	
	#### IS IT ALIVE? IS IT IN RANGE?
	for t in targets:
		if t.checkValidity():
			if isInRangedRange(t):
				targetsInRange.append(t)
	
	var visibleTargets := []
	for t in targetsInRange:
		#### LINE OF SIGHT CONFIRMED
		if actor.isPlayer:
			if t.isVisible:
				visibleTargets.append(t)
		elif world.lineOfSight.lineOfSightBetweenObjects(actor, t):
			visibleTargets.append(t)
			#world.aStar.createDebugLine([actor.position, t.position]) ##DEBUG
			
	return visibleTargets
	
	
	
	
func getTargetGroup() -> Array:
	
	var targets := []
	match targetingGroup:
		
		#### ENEMY -> ALLY, ALLY -> ENEMY
		targetingGroupEnum.ENEMY:
			if actor.isEnemy:
				targets = world.getAllies()
			else:
				targets = world.getEnemies()
		
		#### ENEMY -> ENEMY, ALLY -> ALLY
		targetingGroupEnum.ALLY:
			if actor.isEnemy:
				targets = world.getEnemies()
			else:
				targets = world.getAllies()
				
		targetingGroupEnum.SELF:
			targets = [actor]
	
	return targets
			

func isInRangedRange(target:Node) -> bool:
	
	if GridTools.getEntityGridDistance(actor, target) <= skill.range:
		return true
	return false		
			
			
			
