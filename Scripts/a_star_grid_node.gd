extends Node2D


var RangedLine = load("res://Scenes/MiscUI/RangedShotLine.tscn")

var world:Node = null
var grid:Node = null

var aStarGrid := AStarGrid2D.new()

var aStarNormal := AStar2D.new()

var previouslySeenTiles := []


func setup(world) -> void:
	self.world = world
	self.grid = world.grid
	
	
func setupGrid():
	aStarGrid.region = Rect2i(0,0, 100,100)
	aStarGrid.cell_size = Vector2i(32,32)
	aStarGrid.offset = Vector2i(16,16)
	#aStarGrid.default_compute_heuristic = AStarGrid2D.h
	#aStarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_
	aStarGrid.update()
	
	

func passTurn():
	for node in $Disposables.get_children():
		node.queue_free()
	
	
	
func pathStuff(creature, target):

	var walls = grid.getAllWallTiles()
	for wallTile in walls:
		#showSolidTile(wallTile)
		aStarGrid.set_point_solid(wallTile, true)
			
	var path = aStarGrid.get_point_path(creature.position / 32, target.gridPosition )
	var debugLine:Line2D = createDebugLine(path)
	
	return debugLine


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
		var line:Line2D = RangedLine.instantiate()
		line.points = [current_pos, finalPoint]
		$Disposables.add_child(line)
		return true
		
	return false
	


func lineOfSightInRange(startCoord:Vector2i, coords: Array, tilemap:TileMapLayer):
	
	for coord in previouslySeenTiles:
		tilemap.set_cell(coord, 1, Vector2i(0,0))
	
	var navigator:NavigationAgent2D = world.getPlayer().getNavigator()
	var vec16 := Vector2i(16,16)
	
	var coords32 := []
	var coordsDict := {}
	var visibleCoords := []
	
	#############################################################################
	#### TRANSFORM FROM GRID TO SPATIAL COORDS
	for coord in coords:
		var coord32 = Vector2(coord) * 32 + Vector2(16,16)
		coords32.append(coord32)
		coordsDict[coord32] = coord
	
	#### GET NAVIGATION PATH FROM START TO TARGET. IF STRAIGHT LINE, TARGET IS VISIBLE
	for coord:Vector2 in coords32:
		
		navigator.target_position = coord
		var current_pos = startCoord * 32 + vec16
		var next_path_point = navigator.get_next_path_position()
		var finalPoint = navigator.get_final_position()
		
		if next_path_point == finalPoint and finalPoint in coords32:
			tilemap.set_cell(coordsDict[finalPoint], -1, Vector2i(0,0))
			visibleCoords.append(coordsDict[finalPoint])
			#var points = [current_pos, next_path_point]
			#createDebugLine(points)
	
	###################################################################################
	#### STORE INFO ON COORDS THAT ARE ADJACENT TO PATHABLE COORDS		
	var adjacentCoords := []
	for coord in visibleCoords:      #### EACH VISIBLE FLOOR TILE
		var cords = grid.getCoordsInRange(coord, 1)
		
		for cord in cords:          #### SELF AND EACH ADJACENT TILE TO VISIBLE TILE
			if not cord in adjacentCoords:
				adjacentCoords.append(cord)
	
	var walls := []
	for coord in grid.getAllWallTiles():
		if coord in adjacentCoords:
			walls.append(coord)
		
				
	for coord in walls:
		tilemap.set_cell(coord, -1, Vector2i(0,0))
		
	
	var allSeenTiles = visibleCoords
	allSeenTiles.append_array(walls)
	
	previouslySeenTiles.append_array(allSeenTiles)	
	
	#### CREATURE VISIBILITY
	for creature in world.getCreatures():
		if creature.gridPosition in allSeenTiles:
			creature.show()
		elif creature != world.getPlayer():
			creature.hide()




func createDebugLine(path) -> Line2D:
	
	var debugLine: Line2D = load("res://Scenes/DebugLine.tscn").instantiate()
	$Disposables.add_child(debugLine)
	debugLine.points = []
	for point in path:
		#prints("points:",point)
		debugLine.add_point(point)
	return debugLine




	
func showSolidTile(tilePos):	
	
	var debugSprite = load("res://Scenes/DebugSprite.tscn").instantiate()
	add_child(debugSprite)
	debugSprite.position = tilePos * 32 + Vector2i(16,16)
	
	





#func getLineOfSight(startCoord:Vector2i, coords: Array, tilemap:TileMapLayer):
	#
	#var lines := []
	#
	#for coord:Vector2i in coords:
		#var path = aStarLineOfSight.get_point_path(startCoord, coord )
		#lines.append(createDebugLine(path) ) 
	#
	#for line:Line2D in lines:
		#var isStraight:bool = true
		#if line.points.size() > 2:
			#isStraight = isStraightLine(line.points, line.points[0].direction_to(line.points[1]), 0)
			#
		##if line.points.size() > 2:
		##if not isStraight:
			##line.hide()
		#else:
			#print(line.points)
		#
		#
#
#func isStraightLine(points:Array, direction, index):
	#
	#if index < points.size() - 1:
		#
		#var currentPoint = points[index]
		#var nextPoint = points[index + 1]
		#if currentPoint.direction_to(nextPoint) == direction:
			#return isStraightLine(points, direction, index+1)
		#else:
			#return false
		#
	#else:
		#return true
		


#func getLineOfSightTwo(startCoord:Vector2i, coords: Array, tilemap:TileMapLayer):
	#
	#var ids := []
	#var startId := 0
	#
	#print(coords)
	##ids.append(tilemap.get_cell)
	#
	#var sizeX = coords[coords.size()-1].x - coords[0].x
	#var sizeY = coords[coords.size()-1].y - coords[0].y
	#aStarNormal.reserve_space(sizeX * sizeY * 100)
	#
	#for coord:Vector2i in coords:
		##tilemap.set_cell(coord, -1, Vector2i(0,0) )
		#
		##### CREATE CELL ID, AND SET POINT POSITION AS GRIDPOS * 32
		#var id = getAStarCellId(coord)
		#aStarNormal.add_point(id, coord * 32 + Vector2i(16,16))
		#ids.append(id)
		##### PLAYER POSITION = START POS
		#if coord == startCoord:
			#startId = id
			#prints("START: ", startCoord )
	#
	##### DEBUG
	#print(ids)
	#var paths := []	
	#var lines := []
	#connectPoints(ids)
	#
	#
	#for id in ids:
		#var points := []
		#points.append_array(aStarNormal.get_point_path(startId, id) )
		#paths.append(points)
		#lines.append(createDebugLine(points))
	#
	#print(paths)
		#
#
#func connectPoints(ids):
	#
	#var usedIds := []
	#
	#for id in ids:
		#for id2 in ids:
			#if id != id2:
				#aStarNormal.connect_points(id, id2)
					##usedIds.append_array([id, id2])
	#
#
#func getLineOfSightThree(startCoord:Vector2i, coords:Array, tilemap:TileMapLayer):
	#
	#for coord in coords:
		#var collision_mask := 8
		#var space_state = get_world_2d().direct_space_state
		#var query = PhysicsRayQueryParameters2D.create(startCoord, coord, collision_mask)
		#var result = space_state.intersect_ray(query)
		#print(result)	
#
#
#func getAStarCellId(cell:Vector2)->int:
	#return int(cell.y + cell.x * 2)
