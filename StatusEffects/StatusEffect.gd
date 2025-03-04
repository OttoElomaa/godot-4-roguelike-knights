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

var affectedCreature:Node = null


func setup(skill:Node):
	
	self.skill = skill
	self.actor = skill.actor
	self.world = actor.world
	self.ui = world.getUi()
	
	$StatModifier.setup(self)
	
	for script in $Scripts.get_children():
		script.setup(self)
	

func applyStatus(target:Node):
	
	var text = "%s affects %s with %s!" % [actor.creatureName, target.creatureName, effectName]
	ui.addMessage(text, Color.WHITE)
	
	#### CREATE COPY OF SELF
	var appliedStatus = self.duplicate()
	appliedStatus.setup(skill)
	
	#### ATTACH COPY TO TARGET CREATURE
	target.addStatus(appliedStatus)
	appliedStatus.setMyTarget(target)


	
func setMyTarget(creature:Node):
	self.affectedCreature = creature
	
	
	
func removeStatus():
	$StatModifier.isActive = false
	affectedCreature.addStatus(null)
	self.queue_free()
	

#### CREATURE PASSES ITSELF AS TARGET, EACH TURN
func tickStatus(target:Node, statusHandler:Node):
	
	#### TICK
	if duration > 0:
		duration -= 1
		
	#### IF REACH ZERO -> DELETE SELF
	else:
		var text = "%s recovers from %s..." % [target.creatureName, effectName]
		ui.addMessage(text, Color.WHITE)
		removeStatus()
		return
		
	#### ACTIVATE SCRIPTS
	for script in $Scripts.get_children():
		script.tickStatus(target, statusHandler)



func modifyStats(statsHandler:Node):
	$StatModifier.modifyStats(statsHandler)
