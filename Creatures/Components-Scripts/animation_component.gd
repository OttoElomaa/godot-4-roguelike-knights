extends Node2D


var creature:Node = null



func setup(creature):
	
	self.creature = creature


func playMovementWobble():
	pass


func playMeleeHit():
	$ParticleAnimations.play("MeleeHit")


func reset():
	$ParticleAnimations.play("RESET")
