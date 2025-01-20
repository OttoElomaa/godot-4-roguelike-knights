extends Node


@export var skillIcon:Texture = null
@export var skillName := "Skill Name"
@export var skillType := "Skill Type"

var actor:Node = null
var world:Node = null

var ui:Node = null
		


func setup(actor:Node):
	
	self.actor = actor
	self.world = actor.world
	self.ui = actor.world.getUi()
	
	for skill in self.get_children():
		skill.setup(self)


func activate(target:Node):
	
	match self.skillType:
		
		"melee":
			$MeleeStrike.activate(target)
