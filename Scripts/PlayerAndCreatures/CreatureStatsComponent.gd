extends Node



@export var baseHealth := 10

@export var baseArmor := 0
@export var baseGuard := 0
@export var baseCrit := 0
@export var baseEvasion := 0
@export var baseBlock := 0


var health:StatResource = null

var armor:Stat = null
var block:Stat = null
var evasion:Stat = null

var zeal:StatResource = null

###########################################
var creature: Node = null
var ui: Node = null

var rng := RandomNumberGenerator.new()



class Stat:
	var baseline := 0
	var altered := 0
	var current := 0
	
	func _init(baseline) -> void:
		self.baseline = baseline
		self.altered = baseline
		self.current = baseline


class StatResource:
	var max := 0
	var current := 0
	
	func _init(maximum, current) -> void:
		self.max = maximum
		self.current = current



func setup(creature):
	
	self.creature = creature
	self.ui = creature.world.ui
	
	armor = Stat.new(baseArmor)
	block = Stat.new(baseBlock)
	evasion = Stat.new(baseEvasion)
	
	health = StatResource.new(baseHealth, baseHealth)
	zeal = StatResource.new(100, 0)



func turnStartUpdate():
	resetCurrentToAltered()


func resetCurrentToAltered():
	   #### RESET each stats' current value to its altered baseline value
	self.block.current = self.block.altered
	self.evasion.current = self.evasion.altered


##################################################################################



func takeDamage(amount: int):
	
	var enemyHurtC := Color.DARK_GOLDENROD
	var allyHurtC := Color.INDIAN_RED
	
	var colorToUse: Color = Color.ALICE_BLUE
	if creature.isEnemy:
		colorToUse = enemyHurtC
	else:
		colorToUse = allyHurtC
	
	health.current -= amount
	creature.updateHealthBar(health)
	var damageString : String = creature.creatureName + " takes " + str(amount) + " damage!"
	ui.addLogRow(damageString, colorToUse)
	
	handleCreatureDeath()
	



func handleCreatureDeath():
	
	if health.current > 0:
		return
		
	if not creature.isPlayer:
		
		var deathString:String = creature.creatureName + " died!"
		ui.addMessage(deathString, Color.DARK_CYAN)
		
		if creature.isEnemy:
			ProgressData.enemiesKilled += 1
			ProgressData.gold += 5
		
		creature.queue_free()
	
	if creature.isPlayer:
		if not creature.world.debugImmortalPlayer:
			creature.world.game.showDeathMessage()
			creature.queue_free()


func recoverHealth(amount: int):

	var enemyHealC := Color.CADET_BLUE
	var allyHealC := Color.GREEN_YELLOW
	
	var colorToUse: Color = Color.ALICE_BLUE
	if creature.isEnemy:
		colorToUse = enemyHealC
	else:
		colorToUse = allyHealC
	
	#### CALCULATE HEALTH CHANGE
	var afterHeal:int = health.current + amount
	if afterHeal > health.max:
		health.current = health.max
	else:
		health.current = afterHeal
	
		
	creature.updateHealthBar(health)
	var damageString : String = creature.creatureName + " recovers " + str(amount) + " life!"
	ui.addLogRow(damageString, colorToUse)




func handlePhysicalHit(damage:int) -> bool:
	
	if tryBlock():
		var blockString : String =  "%s blocks %d damage without taking any!" % [creature.creatureName, damage] 
		ui.clearInitialRow()
		ui.addMessage(blockString, Color.DARK_GRAY)
		return false
		
	if tryEvade():
		var evadeString : String =  "%s evades %d damage!" % [creature.creatureName, damage] 
		ui.clearInitialRow()
		ui.addMessage(evadeString, Color.DARK_GRAY)
		return false
		
	
	var reduced = reduceDamageByArmor(damage)
	takeDamage(reduced)
	return true
	

func tryBlock():
	
	var rand = rng.randi_range(0,100)
	if rand < block.current:
		return true
	return false

func tryEvade():
	
	var rand = rng.randi_range(0,100)
	if rand < evasion.current:
		return true
	return false	


func reduceDamageByArmor(damage:int) -> int:
	
	var multiplier = float(100 - armor.current) / 100
	var reducedDamage:int = ceil(damage * multiplier)
	print("damage:%d, multiplier:%d, reduced:%d" % [damage,multiplier,reducedDamage])
	return reducedDamage
