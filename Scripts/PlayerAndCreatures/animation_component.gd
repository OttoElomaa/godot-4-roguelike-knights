extends Node2D


var creature:Node = null



func setup(creature):
	
	self.creature = creature



func playMeleeHit():
	$ParticleAnimations.play("MeleeHit")
