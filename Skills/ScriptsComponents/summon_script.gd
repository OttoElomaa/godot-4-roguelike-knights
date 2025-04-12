extends Node


@export var summonsAmount := 0
@export var SummonCreatureScene: PackedScene = null

var skill:Node = null



func setup(skill):
	self.skill = skill



#### RETURN TARGET=TRUE, RETURN NULL=FALSE
func activate(targets:Array) -> Node:
	
	#### POST TRIGGER MESSAGE, FOR EXAMPLE
	skill.ui.addInitialRow()
	
	skill.ui.saveInitialMessage("%s uses %s" % [skill.actor.creatureName,skill.skillName], Color.WHITE)
	
	
	var count := 0
	var actorPos = skill.actor.gridPosition
	
	for i in range(summonsAmount):
		if summonCreature(actorPos):
			count += 1
	
	#### IF AT LEAST ONE SUMMONED CREATURE, RETURN SUCCESS VALUE
	if count > 0:
		return skill.actor
	else:
		return null



func summonCreature(actorPos:Vector2i) -> bool:
	
	var summonedCreature = SummonCreatureScene.instantiate()
	var emptyTileFound:bool = skill.world.putOnGridAndMap(summonedCreature, actorPos)
	
	#### SPAWN CREATURE  <--GRID FUNC FOUND EMPTY TILE
	if emptyTileFound:
		skill.world.addCreature(summonedCreature)
		var summonText = "%s summons a %s!" % [skill.actor.creatureName,summonedCreature.creatureName]
		skill.ui.addLogRow(summonText, Color.CYAN)
		return true
	
	#### DELETE CREATURE  <--NO FREE TILE FOUND
	else:
		var summonText = "%s failed to summon a creature!" % skill.actor.creatureName
		skill.ui.addMessage(summonText, Color.WHITE)
		summonedCreature.queue_free()
		return false
	
	
	
	
	
	
	
