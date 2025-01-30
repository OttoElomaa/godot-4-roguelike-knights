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
	self.ui = world.getUi()
	
	

func applyStatus():
	pass
	
	
func removeStatus():
	pass
	

func tickStatus():
	pass
