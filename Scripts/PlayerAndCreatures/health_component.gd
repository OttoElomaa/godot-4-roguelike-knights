extends PanelContainer


var creature:Node = null

@export var health := 0
var maxHealth := 0
@onready var healthBar := $HealthBar
@onready var healthLabel := $HealthLabel
var ui: Node = null

var style1 : StyleBoxFlat = preload("res://Resources/HealthBarBasic.tres")
var style2 : StyleBoxFlat = preload("res://Resources/HealthBarDarkRed.tres")



func setup(creature):
	
	self.creature = creature
	maxHealth = health
	
	$HealthBar.max_value = health
	updateVisual()
	ui = creature.world.getUi()
	
	$HealthBarRed.max_value = 100
	$HealthBarRed.value = 100
	

func updateVisual():
		
	$HealthLabel.text = str(health)
	#$HealthBar.value = health
	$HealthBar.value = 0
	
	
	var barWidth = 32
	var diff:float = float(health) / float(maxHealth)
	var alteredWidth:int = ceil(barWidth * diff )
	prints("diff: ", diff)
	prints("health width: ", alteredWidth)
	$HealthBarRed.custom_minimum_size.x = alteredWidth
	
	if health >= maxHealth:
		$HealthBar.hide()
		$HealthBarRed.hide()
	else:
		$HealthBar.show()
		$HealthBarRed.show()
	
	if health < (maxHealth / 2):
		$HealthBarRed.add_theme_stylebox_override("fill", style2)
	else:
		$HealthBarRed.add_theme_stylebox_override("fill", style1)


func takeDamage(amount: int):
	
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
	
	if creature.isEnemy:
		if health <= 0:
			var deathString:String = creature.creatureName + " died!"
			ui.addMessage(deathString, Color.DARK_CYAN)
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
	var afterHeal:int = health + amount
	if afterHeal > maxHealth:
		health = maxHealth
	else:
		health = afterHeal
	
		
	updateVisual()
	var damageString : String = creature.creatureName + " recovers " + str(amount) + " life!"
	ui.addMessage(damageString, colorToUse)
