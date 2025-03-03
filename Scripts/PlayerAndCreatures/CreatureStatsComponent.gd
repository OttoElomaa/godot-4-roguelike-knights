extends Node
class_name CreatureStats


@export var baseHealth := 10

@export var baseArmor := 0
@export var baseBlock := 0
@export var baseEvasion := 0
@export var baseCrit := 0


var health:StatResource = null

var armor:Stat = null
var block:Stat = null
var evasion:Stat = null
var crit:Stat = null

var zeal:StatResource = null
var guard:StatResource = null

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
	crit = Stat.new(baseCrit)
	
	health = StatResource.new(baseHealth, baseHealth)
	zeal = StatResource.new(100, 0)
	guard = StatResource.new(100, 0)



func turnStartUpdate():
	resetCurrentToAltered()


func resetCurrentToAltered():
	   #### RESET each stats' current value to its altered baseline value
	
	armor.current = armor.altered
	block.current = block.altered
	evasion.current = evasion.altered
	


##################################################################################



func takeDamage(amount: int):
	
	var colorToUse:Color = MyColors.fontAllyHurt
	if creature.isEnemy:
		colorToUse = MyColors.fontEnemyHurt
	
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

	var colorToUse:Color = MyColors.fontAllyHeal
	if creature.isEnemy:
		colorToUse = MyColors.fontEnemyHeal
	
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
	
	if tryBlock(damage):
		return false
		
	if tryEvade(damage):
		return false
	
	var reduced := damage	
	if guard.current > 0:
		reduced = reduceDamageByGuard(damage)
	
	if reduced > 0:
		reduced = reduceDamageByArmor(damage)
		takeDamage(reduced)
	return true
	

func tryBlock(damage:int):
	
	var rand = rng.randi_range(0,100)
	if rand < block.current:
		var blockString : String =  "%s blocks %d damage without taking any!" % [creature.creatureName, damage] 
		ui.clearInitialRow()
		ui.addMessage(blockString, MyColors.fontLightBlue)
		
		return true
	return false

func tryEvade(damage:int):
	
	var rand = rng.randi_range(0,100)
	if rand < evasion.current:
		var evadeString : String =  "%s evades %d damage!" % [creature.creatureName, damage] 
		ui.clearInitialRow()
		ui.addMessage(evadeString, MyColors.fontLightBlue)
		
		return true
	return false	


func reduceDamageByGuard(damage:int) -> int:
	
	var curr := guard.current
	var afterGuard := damage
	var reduction := 0
	
	if curr < damage:
		reduction = curr
	else:
		reduction = damage
	afterGuard = damage - reduction
	
	var absorbedAmount = afterGuard
	guard.current -= reduction
	
	var blockString : String =  "%s guards against %d damage and avoids %d!" % [creature.creatureName, damage, reduction] 
	ui.clearInitialRow()
	ui.addMessage(blockString, Color.LIGHT_BLUE)
	
	ui.saveInitialMessage("Guard broken!", Color.LIGHT_BLUE)
	
	return afterGuard


func reduceDamageByArmor(damage:int) -> int:
	
	var multiplier = float(100 - armor.current) / 100
	var reducedDamage:int = ceil(damage * multiplier)
	print("damage:%d, multiplier:%d, reduced:%d" % [damage,multiplier,reducedDamage])
	return reducedDamage
