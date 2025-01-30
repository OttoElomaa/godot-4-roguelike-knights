extends Node



@export var armor := 0
@export var guard := 0
@export var crit := 0
@export var baseEvasion := 0
@export var baseBlock := 0

var block:Stat = null
var evasion:Stat = null


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


func setup(creature):
	
	self.creature = creature
	self.ui = creature.world.ui
	
	block = Stat.new(baseBlock)
	evasion = Stat.new(baseEvasion)
	


func turnStartUpdate():
	resetCurrentToAltered()


func resetCurrentToAltered():
	   #### RESET each stats' current value to its altered baseline value
	self.block.current = self.block.altered
	self.evasion.current = self.evasion.altered



func handlePhysicalHit(damage:int):
	
	if tryBlock():
		var blockString : String =  "%s blocks %d damage without taking any!" % [creature.creatureName, damage] 
		ui.addMessage(blockString, Color.LIGHT_GRAY)
		return
		
	if tryEvade():
		var evadeString : String =  "%s evades %d damage!" % [creature.creatureName, damage] 
		ui.addMessage(evadeString, Color.LIGHT_GRAY)
		return
		
	
	var reduced = reduceDamageByArmor(damage)
	creature.takeDamage(reduced)
	
	

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
	
	var multiplier = float(100 - armor) / 100
	var reducedDamage:int = ceil(damage * multiplier)
	print("damage:%d, multiplier:%d, reduced:%d" % [damage,multiplier,reducedDamage])
	return reducedDamage
