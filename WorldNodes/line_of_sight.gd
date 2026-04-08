extends Node2D


@export var debugShowLOSLines := false

var RangedLine = load("res://MiscUI/RangedShotLine.tscn")

var previouslySeenTiles := []
var visibleTiles := []
var world:Node = null
var grid:GridController = null



func setup(world) -> void:
	self.world = world
	self.grid = world.grid
	
	
			
func passTurn():
	for node in $Disposables.get_children():
		node.queue_free()



func lineOfSightBetweenObjects(object1:Node, object2:Node) -> bool:
	
	#### ADJACENT = VISIBLE
	if GridTools.getEntityGridDistance(object1, object2) < 2:
		return true
	
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
	
	self.visibleTiles = []
	var coordsToCheck:Array = grid.getCoordsInRange(startCoord, range)
	
	var coordsDict := {}
	var visibleCoords := []
	var vec16 := Vector2i(16,16)
	
	
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
		if lineOfSightBetweenTiles(startCoord, coord):
			tilemap.set_cell(coord, -1, Vector2i(0,0))
			visibleCoords.append(coord)
	
	
	
	#### STORE THIS TURN'S VISIBLE COORDS TO LIST THAT'S AVAILABLE VIA WORLD
	self.visibleTiles = visibleCoords
			
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
	
	

########################################################
#### ALGORITHMIC LOS
func lineOfSightBetweenTiles(start: Vector2i, goal: Vector2i) -> bool:
	var distX = abs(goal.x - start.x)
	var distY = abs(goal.y - start.y)

	var sx = 1 if start.x < goal.x else -1
	var sy = 1 if start.y < goal.y else -1

	var err = distX - distY
	var x = start.x
	var y = start.y

	while true:
		if x == goal.x and y == goal.y:
			return true
		var tile = Vector2i(x, y)
		if tile != start and grid.isTileWall(tile):
			return false

		var e2 = 2 * err
		if e2 >= -distY:
			err -= distY
			x += sx
		if e2 <= distX:
			err += distX
			y += sy
	return true
