extends Node


@export var skillIcon:Texture = null
@export var skillName := "Skill Name"
@export var skillType := "Skill Type"

@export var range := 0

var actor:Node = null
var world:Node = null

var ui:Node = null

var selectedTarget: Node = null



func setup(actor:Node):
	
	self.actor = actor
	self.world = actor.world
	self.ui = actor.world.getUi()
	
	$Targeting.setup(self)
		
	for script in $Scripts.get_children():
		script.setup(self)
		
	for e in $StatusEffects.get_children():
		e.setup(self)



func passTurn():
	$Cooldown.tickCooldown()



#### TRY TO PERFORM SKILL ACTIONS
#### SUCCESS=TRUE, FAILURE=FALSE
func activate() -> bool:
	
	if actor.isPlayer:
		print("%s uses %s" % [actor.creatureName, skillName])
	
	var cool = $Cooldown
	if cool.isOnCooldown():
		ui.addMessage( "%s can't use %s (Cooldown %d)" % [actor.creatureName,skillName, cool.currentCooldown], Color.WHITE)
		return false
	
	var targets:Array = $Targeting.handleTargeting()
	
	if targets.is_empty():
		return false
		
	print("enemy in range")
	
	#var success := false
	for script in $Scripts.get_children():
		selectedTarget = script.activate(targets)
		
		
	if selectedTarget != null:
		cool.putOnCooldown()
		applyStatusEffects(selectedTarget)
		return true
		
	return false	
				



func applyStatusEffects(target:Node):
	
	for effect in $StatusEffects.get_children():
		effect.applyStatus(target)

	
