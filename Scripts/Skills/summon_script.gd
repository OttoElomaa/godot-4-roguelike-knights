extends Node


@export var summonsAmount := 0
@export var SummonCreatureScene: PackedScene = null

var skill:Node = null



func setup(skill):
	self.skill = skill



#### SUCCESS=TRUE, FAILURE=FALSE
func activate(targets:Array) -> bool:
	
	
	
	var actorPos = skill.actor.gridPosition
	var creaturePos = skill.world.grid.findEmptyTileInRange(actorPos)
	
	if creaturePos == Vector2i(999,999):
		var summonText = "%s failed to summon a creature!" % skill.actor.creatureName
		skill.ui.addMessage(summonText, Color.WHITE)
		return false
	
	var summonedCreature = SummonCreatureScene.instantiate()
	skill.world.addCreature(summonedCreature)
	prints("Summoned: ", summonedCreature)
	prints("Pos: ",creaturePos)
	
	var summonText = "%s summons a %s!" % [skill.actor.creatureName,summonedCreature.creatureName]
	skill.ui.addMessage(summonText, Color.CYAN)
	
	summonedCreature.gridPosition = creaturePos
	skill.world.grid.placeGridObjectOnMap(summonedCreature, creaturePos)
	
	return true
