extends Node2D



var targetsDict := {}

var world:Node = null
var grid:Node = null
var player:Node = null
var lineOfSight:Node = null

var gridPosition := Vector2i.ZERO

#### FOR SHUFFLING THROUGH TARGETS
var selectionNum := 0
var selectedTarget:Node = null



func setup(world) -> void:
	self.world = world
	self.grid = world.grid
	self.player = world.player
	self.lineOfSight = world.lineOfSight
	
	

func createTargetingDict():
	
	targetsDict = {}
	var creatures = world.getCreatures()
	
	var counter = 0
	for creature:Node in creatures:
		counter = addToDictHelp(creature, counter)
	

func addToDictHelp(creature:Node, counter:int) -> int:	
	#### THIS FUNC ONLY TARGETS ENEMIES
	if not creature.isEnemy:
		return counter
	#### ONLY CREATURES THAT ARE ALIVE
	if not creature.checkValidity():
		return counter
	if not creature.isVisible:
		return counter
		
	#### ADD TO LIST
	targetsDict[counter] = creature
	counter += 1
	return counter



func autoSetTarget():
	
	selectionNum = 0
	
	#### NOTHING TO TARGET?
	if targetsDict.is_empty():
		setTarget(null)
		return
	
	#### SET CLOSEST CREATURE AS TARGET
	var closestCreature = GridTools.findClosestCreature(player, targetsDict.values())
	
	#### IF SELECTED TARGET IS STILL CLOSE AND VISIBLE, DON'T CHANGE TARGET
	if not selectedTarget:
		setTarget(closestCreature)
	elif not selectedTarget.isVisible:
		setTarget(closestCreature)
	else:
		var distTarget = GridTools.getEntityGridDistance(player, selectedTarget)
		var distClosest = GridTools.getEntityGridDistance(player, closestCreature)
		if distClosest < distTarget:
			setTarget(closestCreature)
		else:
			setTarget(selectedTarget)
	
	#### BETTER SELECTION NUM MANAGEMENT FOR BROWSING THROUGH TARGETS
	for key in targetsDict.keys():
		if targetsDict[key] == closestCreature:
			selectionNum = key
	
		

func setTarget(creature:Node):
	
	selectedTarget = creature
	player.selectedTarget = creature
	if selectedTarget == null:
		$TargetingIcon.hide()
		return
	
	$TargetingIcon.show()
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
	selectionNum += 1
	if selectionNum > dictSize - 1:
		selectionNum = 0	
	
	
	print("target %d out of %d" % [selectionNum, dictSize])
	prints("Target name: ", targetsDict[selectionNum].creatureName)
	setTarget(targetsDict[selectionNum])
	world.ui.showTargetCreature(player.selectedTarget)
	
				
			
			
			
