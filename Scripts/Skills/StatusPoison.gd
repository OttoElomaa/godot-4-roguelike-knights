extends Node


@export var damage := 0

var effect:Node = null

func setup(effect:Node):
	
	self.effect = effect

func tickStatus(target:Node):
	
	var text = "%s is %s... (%d)" % [target.creatureName, effect.effectedTitle, effect.duration]
	effect.ui.saveInitialMessage(text, Color.WHITE)
	target.stats.takeDamage(damage)
	
