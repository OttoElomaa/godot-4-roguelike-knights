extends Node


@export var skillIcon:Texture = null
@export var skillName := "Skill Name"
@export var skillType := "Skill Type"

@export var range := 0

var actor:Node = null
var world:Node = null

var ui:Node = null

enum targetingGroupEnum {
	SELF, ENEMY, ALL_ENEMIES, ALLY, ALL_ALLIES
}	
@export var targetingGroup:targetingGroupEnum = targetingGroupEnum.ENEMY


func setup(actor:Node):
	
	self.actor = actor
	self.world = actor.world
	self.ui = actor.world.getUi()
	
	for skill in $Scripts.get_children():
		skill.setup(self)

#### TRY TO PERFORM SKILL ACTIONS
#### SUCCESS=TRUE, FAILURE=FALSE
func activate(target:Node) -> bool:
	
	if not isInRangedRange(target):
		return false
		
	print("enemy in range")
	
	for script in $Scripts.get_children():
		script.activate(target)
		
	return false	
	
	#match self.skillType:
		#"melee":
			#print("melee attack")
			#return $MeleeStrike.activate(target)
		#"ranged":
			#print("ranged attack")
			#return $RangedShot.activate(target)
			
	

func isInRangedRange(target:Node) -> bool:
	
	if world.grid.getGridDistance(actor, target) <= self.range:
		return true
	return false


func isInRange(target:Node) -> bool:
	
	var adjacentTiles = world.grid.getCoordsInRange(actor.gridPosition, range)
	if target.gridPosition in adjacentTiles:
		return true
	return false
