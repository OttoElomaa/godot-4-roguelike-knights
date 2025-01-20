extends Node2D


var creature:Node = null

@export var health := 0
var maxHealth := 0
@onready var healthBar := $HealthBar
@onready var healthLabel := $HealthLabel
var ui: Node = null


func setup(creature):
	
	self.creature = creature
	maxHealth = health
	updateVisual()
	ui = creature.world.getUi()


func updateVisual():
		
	$HealthLabel.text = str(health)
	$HealthBar.max_value = health
	$HealthBar.value = health

func takeDamage(amount):
	
	health -= amount
	updateVisual()
	ui.addMessage(creature.creatureName + " takes " + str(amount) + " damage!")
	
