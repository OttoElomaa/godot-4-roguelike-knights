extends Node2D


@export var debugShowLOSLines := false

var RangedLine = load("res://MiscUI/RangedShotLine.tscn")

var previouslySeenTiles := []
var world:Node = null
var grid:Node = null



func setup(world) -> void:
	self.world = world
	self.grid = world.grid
	
	
			
func passTurn():
	for node in $Disposables.get_children():
		node.queue_free()



func lineOfSightBetweenObjects(object1:Node, object2:Node) -> bool:
	
	#### OBJECT 1'S NAVIGATION AGENT SETS OBJECT 2 AS ITS TARGET
	#### THEN CREATE PATH
	var navigator = object1.getNavigator()
	navigator.target_position = object2.gridPosition * 32 + Vector2i(16,16)
	
	var current_pos = object1.gridPosition * 32 + Vector2i(16,16)
	var next_path_point = navigator.get_next_path_position()
	var finalPoint = navigator.get_final_position()
		
	#### IF PATH IS DIRECT STRAIGHT LINE, RETURN TRUE
	if next_path_point == finalPoint:
		
		return true
		
	return false


func createRangedLine(startPos, endPos):
	var line:Line2D = RangedLine.instantiate()
	line.points = [startPos, endPos]
	$Disposables.add_child(line)



#### COORDS: Grid.getCoordsInRange(gridPos, distance)
#### PreviouslySeenTiles: WE UPDATE IT IN THIS FUNC
func handleFogOfWar(startCoord:Vector2i, range:int, tilemap:TileMapLayer):
	
	#### PUT NAVIGATOR TO PLAYER'S CURRENT GRID POSITION (Where player stands / is moving to)
	$Mover.position = GridTools.gridToWorld(startCoord)
	
	var coordsToCheck:Array = grid.getCoordsInRange(startCoord, range)
	
	var coordsDict := {}
	var visibleCoords := []
	var vec16 := Vector2i(16,16)
	
	var current_pos = startCoord * 32 + vec16
	
	#### SET AS UNSEEN DARK FOG (Value 0)
	for coord in coordsToCheck:
		tilemap.set_cell(coord, 0, Vector2i(0,0))
		
	#### SET PREVIOUSLY SEEN TILES AS FOGGY TEXTURE. NOT VOIDTILES (Value 1)
	for coord in previouslySeenTiles:
		if grid.getTileValue(coord) in [-1,2]:
			tilemap.set_cell(coord, 1, Vector2i(0,0))
	
	#############################################################################
	#### TRANSFORM EACH COORD FROM GRID TO SPATIAL
	#### DICTIONARY - KEY:SPATIAL, VALUE: GRID COORD
	for coord in coordsToCheck:
		var spatial = Vector2(coord) * 32 + Vector2(16,16)
		coordsDict[spatial] = coord
	
	
	############################################################################
	#### GET NAVIGATION PATH FROM START TO TARGET. ONLY IF PASSABLE TILE 
	for coord:Vector2 in coordsDict.keys():
		
		if grid.getTileValue(coordsDict[coord]) == -1:
			if coordsDict[coord] in grid.regionTiles:
				#### PROCESS EACH TILE'S SIGHT LINE HERE - IMPORTANT
				inRangeHelp(coordsDict, coord, tilemap, visibleCoords)
				
				
	###################################################################################
	#### STORE INFO ON COORDS THAT ARE ADJACENT TO PATHABLE COORDS		
	var adjacentCoords := []
	for coord in visibleCoords:      #### EACH VISIBLE FLOOR TILE
		
		#### SELF AND EACH ADJACENT TILE TO VISIBLE TILE
		for c in grid.getCoordsInRange(coord, 1):          
			if not c in adjacentCoords:
				adjacentCoords.append(c)
	
	
	#### MAKE VISIBLE: WALLS ADJACENT TO VISIBLE FLOOR TILES
	var walls := []
	for coord in adjacentCoords:
		if grid.getTileValue(coord) == 2:
			walls.append(coord)		
					
	for coord in walls:
		tilemap.set_cell(coord, -1, Vector2i(0,0))
	
	####THIS ARRAY GROWS EVERY TIME THIS FUNCTION IS DONE ON NEW TILES	
	var allSeenTiles = visibleCoords
	allSeenTiles.append_array(walls)
	
	for pos in allSeenTiles:
		if not pos in previouslySeenTiles:
			previouslySeenTiles.append(pos)
	
	
	########################################
	#### CREATURE VISIBILITY
	for creature in world.getCreatures():
		#### IS IN SEEN TILES -> VISIBLE
		if creature.gridPosition in allSeenTiles:
			creature.show()
			creature.isVisible = true
		#### NOT IN SEEN TILES, NOT PLAYER -> HIDE
		elif creature != world.player:
			creature.hide()
			creature.isVisible = false

	
	
	#### IF EMPTY VOID TILE, MAKE IT HIDDEN FOG
	for coord in coordsToCheck:
		if grid.getTileValue(coord) == 1:
			tilemap.set_cell(coord, 0, Vector2i(0,0))
	
	

func inRangeHelp(coordsDict:Dictionary, coord:Vector2, tilemap:TileMapLayer, visibleCoords:Array):
	
	var navigator := $Mover/LineOfSightNavigator
	
	#### IF PATH IS STRAIGHT LINE, TARGET IS VISIBLE
	navigator.target_position = coord
	var startingPoint = GridTools.gridToWorld( world.player.gridPosition )
	var finalPoint = navigator.get_final_position()
	
	#### LINEAR DISTANCE:
	var straightDistance = startingPoint.distance_to(coord)
	
	#### CALCULATE PATH LENGTH, COMPARE TO SEE IS IT LINEAR
	var points = navigator.get_current_navigation_path()
	var dist := 0
	for i in range(1, points.size()):
		
		var new:Vector2 = points[i]
		var prev = points[i-1]
		dist += new.distance_to(prev)

	
	#### IF LINE IS STRAIGHT, IT'S IN LINE OF SIGHT
	if dist <= straightDistance:
		tilemap.set_cell(coordsDict[coord], -1, Vector2i(0,0))
		visibleCoords.append(coordsDict[coord])
		
		#### DEBUG TO SEE Successful SIGHT LINES
		if debugShowLOSLines:
			var line:Line2D = RangedLine.instantiate()
			#line.points = [startingPoint, finalPoint]
			line.points = points
			$Disposables.add_child(line)
