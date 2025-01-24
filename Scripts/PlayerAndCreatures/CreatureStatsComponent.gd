extends Node



@export var armor := 0
@export var guard := 0
@export var crit := 0
@export var evade := 0
@export var block := 0

var creature: Node = null
var ui: Node = null

var rng := RandomNumberGenerator.new()


func setup(creature):
	
	self.creature = creature
	self.ui = creature.world.ui
	
	

func handlePhysicalHit(damage:int):
	
	if tryBlock():
		var blockString : String =  "%s blocks %d damage without taking any!" % [creature.creatureName, damage] 
		ui.addMessage(blockString, Color.LIGHT_GRAY)
	else:
		var reduced = reduceDamageByArmor(damage)
		creature.takeDamage(reduced)
	
	

func tryBlock():
	
	var rand = rng.randi_range(0,100)
	if rand < block:
		return true
	return false
	


func reduceDamageByArmor(damage:int) -> int:
	
	var multiplier = float(100 - armor) / 100
	var reducedDamage:int = ceil(damage * multiplier)
	print("damage:%d, multiplier:%d, reduced:%d" % [damage,multiplier,reducedDamage])
	return reducedDamage
