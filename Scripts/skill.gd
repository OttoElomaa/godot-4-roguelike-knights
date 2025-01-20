extends Node


@export var skillIcon:Texture = null
@export var skillName := "Skill Name"
@export var skillType := "Skill Type"

@export var range := 0

var actor:Node = null
var world:Node = null

var ui:Node = null




func setup(actor:Node):
	
	self.actor = actor
	self.world = actor.world
	self.ui = actor.world.getUi()
	
	$Targeting.setup(self)
		
	for skill in $Scripts.get_children():
		skill.setup(self)



#### TRY TO PERFORM SKILL ACTIONS
#### SUCCESS=TRUE, FAILURE=FALSE
func activate(target:Node) -> bool:
	
	
	var targets:Array = $Targeting.handleTargeting()
	
	if targets.is_empty():
		return false
		
	print("enemy in range")
	
	var success := false
	for script in $Scripts.get_children():
		success = script.activate(targets)
		
	return success	
				



	
