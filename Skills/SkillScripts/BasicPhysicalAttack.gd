extends Node



var skill:Node = null
var actor:Node = null

@export var damage := 0
@export var attacksCount := 0

@export var isRanged := false


func setup(skill):
	self.skill = skill
	self.actor = skill.actor


#### RETURN TARGET=TRUE, RETURN NULL=FALSE
func activate(targets:Array) -> Node:
	
	#### NPC's GET TARGET FROM FILTERED LIST
	#### ALSO AUTO-TARGETING SKILLS VIA BOONS ETC
	var target = targets[0]
	var ref: SkillUseRef = skill.skillUseRef
	
	#### MANUAL TARGET SELECTION - FOR MANUAL SKILL USE ONLY
	if actor.isPlayer:
		if skill.myEffect == null:
			target = actor.selectedTarget
	#### IDK
	if not target:
		return null
	
	#### POST TRIGGER MESSAGE, FOR EXAMPLE
	skill.ui.addInitialRow()
	
	#### CREATE FIRST HALF OF DOUBLE MESSAGE
	var actorWeapon = actor.getWeapon()
	var creName = skill.actor.creatureName
	var skillStr = "%s uses %s (%s)" % [creName, skill.skillName, actorWeapon.itemName]
	
	skill.ui.saveInitialMessage(skillStr, Color.WHITE)
	print(skillStr)
	
	skill.printBoonText()
	

	
	
	var success = false
	#### JUST LOG ROW FORMATTING Stuff Atm
	handleMultiAttack()
	
	#### LAUNCH A NUMBER OF ATTACKS (1 or more)
	#### CHECK If Creature Is Alive EACH TIME
	for i in range(attacksCount):
		if target.checkValidity():
			
			var weaponDamage = damage + actorWeapon.getRealDamage(actor) + skill.getZealEnhanceAmount()
			
			var newSuccess:bool = target.stats.handlePhysicalHit(weaponDamage)
			if newSuccess:
				success = true
	
	#### POST THE FIRST HALF IF LAST HALF FAILS
	#if not success:
		#skill.ui.clearInitialRow()
	if success:
		actor.playAttackAnimation()
	
	if isRanged:
		var start = GridTools.gridToWorld(actor.gridPosition)
		var end = GridTools.gridToWorld(target.gridPosition)
		skill.world.lineOfSight.createRangedLine(start, end)
		
	return target
	

func handleMultiAttack():
	if attacksCount > 1:
		skill.ui.addInitialRow()
		skill.ui.saveInitialMessage("(%s) " % skill.skillName, MyColors.fontLightBlue)
