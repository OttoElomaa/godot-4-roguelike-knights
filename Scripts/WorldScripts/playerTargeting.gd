extends Node2D



var targetsDict := {}

var world:Node = null
var grid:Node = null
var player:Node = null
var lineOfSight:Node = null

var gridPosition := Vector2i.ZERO

#### FOR SHUFFLING THROUGH TARGETS
var selectionNum := 0


func setup(world) -> void:
	self.world = world
	self.grid = world.grid
	self.player = world.player
	self.lineOfSight = world.lineOfSight
	
	

func createTargetingDict():
	
	targetsDict = {}
	var creatures = world.getCreatures()
	
	var counter = 0
	for creature in creatures:
		if creature == player:
			pass
		elif not creature.isEnemy:
			pass
		elif lineOfSight.lineOfSightBetweenObjects(player, creature):
			if is_instance_valid(creature):
				targetsDict[counter] = creature
				counter += 1
			

func autoSetTarget():
	
	selectionNum = 0
	
	#### NOTHING TO TARGET?
	if targetsDict.is_empty():
		$TargetingIcon.hide()
		player.selectedTarget = null
		return
	else:
		$TargetingIcon.show()
	
	#### PICK CLOSEST TARGET
	var closest:Node = targetsDict.values()[0]
	for creature in targetsDict.values():
		var distCre = grid.getGridDistance(player, creature)
		var distClose = grid.getGridDistance(player, closest)
		
		if distCre <= distClose:
			closest = creature
	
	setTarget(closest)
		
	#self.position = closest.position
		

func setTarget(creature:Node):
	
	player.selectedTarget = creature
	self.gridPosition = creature.gridPosition
	grid.matchPositionToGridPos(self)	


func shuffleTargets():
	
	#### NOTHING TO TARGET?
	if targetsDict.is_empty():
		$TargetingIcon.hide()
		player.selectedTarget = null
		return
	else:
		$TargetingIcon.show()
	
	var dictSize = targetsDict.size()
	
	#### SHUFFLE THROUGH THEIR NUMBER TAGS. HITTING TOP RETURNS TO START
	if selectionNum < dictSize - 1:
		selectionNum += 1
		
	else:
		selectionNum = 0
	
	print("target %d out of %d" % [selectionNum, dictSize])
	prints("Target name: ", targetsDict[selectionNum].creatureName)
	setTarget(targetsDict[selectionNum])
				
			
			
			
