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
	
	var enemyHurtC := Color.DARK_GOLDENROD
	var allyHurtC := Color.INDIAN_RED
	
	var colorToUse: Color = Color.ALICE_BLUE
	if creature.isEnemy:
		colorToUse = enemyHurtC
	else:
		colorToUse = allyHurtC
	
	health -= amount
	updateVisual()
	var damageString : String = creature.creatureName + " takes " + str(amount) + " damage!"
	ui.addMessage(damageString, colorToUse)
	
