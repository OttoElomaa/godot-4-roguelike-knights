extends Node


var creature:Node = null
var world:Node = null

var isStunned := false


func setup(creature):
	self.creature = creature
	self.world = creature.world
	
	for boon in get_children():
		if boon.isBoon:
			boon.setup(null, creature)


func getBoons() -> Array:
	var boons := []
	for effect in get_children():
		if effect.isBoon:
			boons.append(effect)
	return boons


#### CALLED IN Creature.StartTurn
func tickStatus():
	isStunned = false
	
	for effect in get_children():
		if not effect.isBoon:
			effect.tickStatus(creature, self)


#### ADD STATUS DURING SKILL USE
func addStatus(effect:Node):
	add_child(effect)



func modifyStats(statsHandler:Node):
	#### CLEAR MODIFICATIONS
	statsHandler.turnStartUpdate() 
	#### COUNT THE MODIFICATIONS
	for effect in get_children():
		effect.modifyStats(statsHandler)
