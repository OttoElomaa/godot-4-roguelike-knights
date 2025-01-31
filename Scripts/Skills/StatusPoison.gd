extends Node


@export var damage := 0

var effect:Node = null

func setup(effect:Node):
	
	self.effect = effect

func tickStatus(target:Node):
	
	var text = "%s takes damage from %s... (%d)" % [target.creatureName, effect.effectName, effect.duration]
	effect.ui.addMessage(text, Color.WHITE)
	target.stats.takeDamage(damage)
	
