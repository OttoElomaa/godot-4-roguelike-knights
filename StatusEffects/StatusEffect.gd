extends Node


enum BoonTypes {
	NONE, SELF_STEP, ADJACENT_STEP, RECEIVE_PHYS_ATTACK, CREATURE_DEATH
}

@export var isBoon := false
@export var boonType := BoonTypes.NONE

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


#### BOON'S OWNER IS THE CREATURE IT'S ATTACHED TO
func setup(skill:Node, owner:Node):
	
	#BASIC SETUP
	self.actor = owner
	self.world = owner.world
	self.ui = world.ui
	
	$StatModifier.setup(self)
	for script in $Scripts.get_children():
		script.setup(self)
	for scene in $Skills.get_children():
		scene.setup(owner)	
	
	#### END OF BOON SETUP - NO SKILL ATTACHED
	if boonType != BoonTypes.NONE:
		return
	
	#### SKILL STATUS EFFECTS, ATTACHED TO SKILL
	self.skill = skill
	
	
	
	
	
	

func applyStatus(target:Node):
	
	var text = "%s affects %s with %s!" % [actor.creatureName, target.creatureName, effectName]
	ui.addMessage(text, MyColors.fontStatusC)
	
	#### CREATE COPY OF SELF
	var appliedStatus = self.duplicate()
	appliedStatus.setup(skill, actor)
	
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
		var text = "%s is no longer %s..." % [target.creatureName, effectedTitle]
		ui.addMessage(text, MyColors.fontStatusC)
		removeStatus()
		return
		
	#### ACTIVATE SCRIPTS
	tickScripts(target, statusHandler)
	
	

func tickScripts(target:Node, statusHandler:Node):
	#### GO THROUGH EACH SCRIPT. SKILL SCRIPTS ARE ACTIVATED. STATUS SCRIPTS ARE TICKED
	for script in $Scripts.get_children():
		script.tickStatus(target, statusHandler)
	for scene in $Skills.get_children():
		scene.activate()



func modifyStats(statsHandler:Node):
	$StatModifier.modifyStats(statsHandler)



func triggerBoons(boonType:BoonTypes, target:Node):
	
	#### DON'T TRIGGER IF IT'S AGAINST RESTRICTIONS (Must stand still, Etc...)
	if not $Restrictions.checkRestrictions(target):
		return
		
	if boonType == self.boonType:
		var text = "%s triggers %s!" % [target.creatureName, effectName]
		print(text)
		ui.saveInitialMessage(text, Color.DARK_ORANGE)
		
		tickScripts(target, target.status)
			
