extends Node



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
		ui.addMessage(blockString, Color.WHITE)
	else:
		creature.takeDamage(damage)
	
	

func tryBlock():
	
	var rand = rng.randi_range(0,100)
	if rand < block:
		return true
	return false
	
	
