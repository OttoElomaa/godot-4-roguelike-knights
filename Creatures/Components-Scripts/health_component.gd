extends PanelContainer


var creature:Node = null
var ui: Node = null

@onready var healthBar := $HealthBar

var style1 : StyleBoxFlat = preload("res://Resources/HealthBarBasic.tres")
var style2 : StyleBoxFlat = preload("res://Resources/HealthBarDarkRed.tres")

var barWidth = 32
var guardMaxVisual := 20



func setup(creature):
	
	self.creature = creature
	var s = creature.stats
	var health = creature.stats.health
	var guard = creature.stats.guard
	
	updateVisual(health, guard)
	ui = creature.world.ui
	


func updateVisual(health:Object, guard:Object):
	
	#### DISPLAY STUFF
	if guard.current > 0:
		self.show()
		$GuardBarBlue.show()
	else:
		$GuardBarBlue.hide()
		if health.current >= health.max:
			self.hide()
		else:
			self.show()
	
		
	#### HEALTH BAR STUFF
	#if health.current < health.max:	
	var diff:float = float(health.current) / float(health.max)
	var alteredWidth:int = ceil(barWidth * diff )
	prints("diff: ", diff)
	prints("health width: ", alteredWidth)
	$HealthBarRed.custom_minimum_size.x = alteredWidth
	
	
	if guard.current > 0:		
		var diffg:float = float(guard.current) / float(guardMaxVisual)
		var altWidthG:int = ceil(barWidth * diffg )
		$GuardBarBlue.custom_minimum_size.x = altWidthG
	
	
	if health.current < (health.max / 2):
		$HealthBarRed.add_theme_stylebox_override("fill", style2)
	else:
		$HealthBarRed.add_theme_stylebox_override("fill", style1)
