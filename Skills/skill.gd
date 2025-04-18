extends Node


@export var skillIcon:Texture = null
@export var skillName := "Skill Name"
@export var skillType := "Skill Type"

@export var range := 0

var actor:Node = null
var world:Node = null

var ui:Node = null

var selectedTarget: Node = null

#### THIS SKILL CAN BE ATTACHED TO AN EFFECT, like a boon
var skillUseRef: SkillUseRef = null
var myEffect: Node = null

#### RESOURCE STUFF
var zealGain := 0
var zealCost := 0
var zealEnhance := 0

var guardGain := 0
var guardCost := 0
var guardEnhance := 0



func setup(actor:Node):
	
	self.actor = actor
	self.world = actor.world
	self.ui = actor.world.ui
	
	$Targeting.setup(self)
	
	for script in $Scripts.get_children():
		script.setup(self)
		
	for e in $StatusEffects.get_children():
		e.setup(self, actor)
	
	#### ALSO SETS UP	
	for script in $Resources.get_children():
		script.setup(self)
		script.setSkillResources(self)



func passTurn():
	return $Cooldown.tickCooldown()



#### TRY TO PERFORM SKILL ACTIONS
#### SUCCESS=TRUE, FAILURE=FALSE
func activate() -> bool:
	
	#### RECORDING SKILL USE REFERENCE INFO
	if skillUseRef == null:
		skillUseRef = SkillUseRef.new()
		skillUseRef.actor = actor
	
	skillUseRef.skill = self
	
		
	#### RESOURCES - CHECK FOR COST - CAN'T USE IF CAN'T PAY
	if zealCost > 0:
		if zealCost > actor.stats.zeal.current:
			print("%s can't use %s (Not enough Zeal)" % [actor.creatureName, skillName])			
			return false
	
	#### COOLDOWN
	var cool = $Cooldown
	if cool.isOnCooldown():
		var cooldownText = "%s can't use %s (Cooldown %d)" % [actor.creatureName, skillName, cool.currentCooldown]
		print(cooldownText)
		if actor.isPlayer:
			ui.addMessage( cooldownText, Color.WHITE)
		return false
	
	#### TARGETING
	var targets:Array = $Targeting.handleTargeting()
	if targets.is_empty():
		return false
		
	#### USE SCRIPTS - COLLECT WHAT TARGET THEY PICKED
	for script in $Scripts.get_children():
		selectedTarget = script.activate(targets)
		
	#### IF TARGET WAS FOUND
	#### SUCCESS
	if selectedTarget != null:
		handleSuccess()
		return true
	
	#### NO TARGET FOUND	
	return false	



#### THESE ACTIONS ARE DONE WHEN SKILL USE IS SUCCESSFUL
func handleSuccess():			
	$Cooldown.putOnCooldown()
	applyStatusEffects(selectedTarget)
	
	#### RESOURCE MANAGEMENT
	actor.stats.zeal.current += zealGain
	actor.stats.guard.current += guardGain
	
	actor.stats.zeal.current -= zealCost


#############################################################

func passBoonReference(ref: SkillUseRef):	
	skillUseRef = ref


func applyStatusEffects(target:Node):
	for effect in $StatusEffects.get_children():
		effect.applyStatus(target)


func isOnCooldown() -> bool:
	return $Cooldown.isOnCooldown()


func getCooldown():
	return $Cooldown.currentCooldown	


func getCostString() -> String:
	
	#### STRING MEANS SKILL CAN'T BE USED
	if zealCost > actor.stats.zeal.current:
		return "%d Zeal" % zealCost
	
	#### EMPTY STRING = IS USABLE	
	return ""


func getZealEnhanceAmount() -> int:
	
	var amount = actor.stats.zeal.current
	if zealEnhance > 0:
		if amount > 0:
			print("Enhanced: %d Zeal * %d multiplier")
	
	return zealEnhance * amount



func printBoonText():
	var ref = skillUseRef
	var boonText = ""
	
	if ref.boon:
		boonText = "Boon: %s" % ref.boon.effectName
	if ref.item:
		boonText += " Item: %s" % ref.item.itemName
	
	print(boonText)
