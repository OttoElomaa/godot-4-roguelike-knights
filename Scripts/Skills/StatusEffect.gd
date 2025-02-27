extends Node


enum targetingGroupEnum {
	SELF, ENEMY, ALL_ENEMIES, ALLY, ALL_ALLIES
}	
@export var targetingGroup:targetingGroupEnum = targetingGroupEnum.ENEMY

@export var effectName := "Effect Name"
@export var effectedTitle := "Effect Name"

@export var duration := 0

var skill:Node = null
var actor:Node = null
var world:Node = null
var ui:Node = null



func setup(skill:Node):
	
	self.skill = skill
	self.actor = skill.actor
	self.world = actor.world
	self.ui = world.getUi()
	
	for script in $Scripts.get_children():
		script.setup(self)
	

func applyStatus(target:Node):
	
	var text = "%s affects %s with %s!" % [actor.creatureName, target.creatureName, effectName]
	ui.addMessage(text, Color.WHITE)
	
	var appliedStatus = self.duplicate()
	appliedStatus.setup(skill)
	target.addStatus(appliedStatus)
	
	#
	
	
func removeStatus():
	pass
	

#### CREATURE PASSES ITSELF AS TARGET, EACH TURN
func tickStatus(target:Node, statusHandler:Node):
	
	#### TICK
	if duration > 0:
		duration -= 1
		
	#### IF REACH ZERO -> DELETE SELF
	else:
		var text = "%s recovers from %s..." % [target.creatureName, effectName]
		ui.addMessage(text, Color.WHITE)
		self.queue_free()
		return
		
	#### ACTIVATE SCRIPTS
	for script in $Scripts.get_children():
		script.tickStatus(target, statusHandler)
