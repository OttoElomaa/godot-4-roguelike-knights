extends PanelContainer


var creature:Node = null

var health = null
#var maxHealth := 0
@onready var healthBar := $HealthBar
var ui: Node = null

var style1 : StyleBoxFlat = preload("res://Resources/HealthBarBasic.tres")
var style2 : StyleBoxFlat = preload("res://Resources/HealthBarDarkRed.tres")



func setup(creature):
	
	self.creature = creature
	var health = creature.stats.health
	var guard = creature.stats.guard
	
	updateVisual(health, guard)
	ui = creature.world.getUi()
	


func updateVisual(health:Object, guard:Object):
	
	var barWidth = 32	
	
	#### GUARD BAR STUFF		
	var guardMax := 50
	
	#if creature.isPlayer:
		#prints("show guard? , ", guard.current)
	
	#### DISPLAY STUFF
	if guard.current > 0:
		self.show()
		$GuardBarBlue.show()
	else:
		#if creature.isPlayer:
			#prints("no show guard? , ", guard.current)
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
		var diffg:float = float(guard.current) / float(guardMax)
		var altWidthG:int = ceil(barWidth * diffg )
		$GuardBarBlue.custom_minimum_size.x = altWidthG
	
	#else:
		#
			
	
	if health.current < (health.max / 2):
		$HealthBarRed.add_theme_stylebox_override("fill", style2)
	else:
		$HealthBarRed.add_theme_stylebox_override("fill", style1)
