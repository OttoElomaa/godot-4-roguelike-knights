extends PanelContainer


var creature:Node = null

var health = null
#var maxHealth := 0
@onready var healthBar := $HealthBar
@onready var healthLabel := $HealthLabel
var ui: Node = null

var style1 : StyleBoxFlat = preload("res://Resources/HealthBarBasic.tres")
var style2 : StyleBoxFlat = preload("res://Resources/HealthBarDarkRed.tres")



func setup(creature):
	
	self.creature = creature
	var health = creature.stats.health
	#maxHealth = health
	
	#$HealthBar.max_value = 100
	updateVisual(health)
	ui = creature.world.getUi()
	
	#$HealthBarRed.max_value = 100
	#$HealthBarRed.value = 100
	

func updateVisual(health):
	
	var barWidth = 32	
	
	#### HEALTH BAR STUFF
	if health.current >= health.max:
		$HealthBar.hide()
		$HealthBarRed.hide()
	else:
		$HealthBar.show()
		$HealthBarRed.show()
		
		
		var diff:float = float(health.current) / float(health.max)
		var alteredWidth:int = ceil(barWidth * diff )
		prints("diff: ", diff)
		prints("health width: ", alteredWidth)
		$HealthBarRed.custom_minimum_size.x = alteredWidth
	
	#### GUARD BAR STUFF		
	var guard = creature.stats.guard
	var guardMax := 50
	
	if guard.current > 0:
		$HealthBar.show()
		$GuardBarBlue.show()
		
		var diff:float = float(guard.current) / float(guardMax)
		var alteredWidth:int = ceil(barWidth * diff )
		$GuardBarBlue.custom_minimum_size.x = alteredWidth
	
	else:
		$GuardBarBlue.hide()
			
	
	if health.current < (health.max / 2):
		$HealthBarRed.add_theme_stylebox_override("fill", style2)
	else:
		$HealthBarRed.add_theme_stylebox_override("fill", style1)
