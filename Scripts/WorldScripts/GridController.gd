extends Node


var tileSize := 32

var world: Node = null
var roomsList := []

var wallTilemapsDict := {}
var floorTilemapsDict := {}

var wallTiles := []
var floorTiles := []
var nonVoidTiles := []
var voidTiles := []

#### ALL TILES WITHIN ANY ROOM'S BACKDROP SQUARE
var regionTiles := []

var voidTilemap:TileMapLayer = null


# Called when the node enters the scene tree for the first time.
func setup(world: Node):
	self.world = world
	
	if world.isOverworld:
		return
		
	self.voidTilemap = world.voidTilemap
	
	
	
func setupGrid():
	
	
	if world.isOverworld:
		return
	
	#### SETUP WALLS AND FLOORS TILE LISTS HERE
	roomsList = world.getRooms()
	createRoomsDictionary(roomsList)	
	nonVoidTiles = getWallAndFloorTiles()
	
	#### STORE TILE INFO IN A TILEMAP AT WORLD
	
	var pointlessReturn = createVoidTiles(voidTilemap)
	return pointlessReturn
	



#### THIS IS THE CATCH-ALL FUNCTION FOR PLACING STUFF ON THE GRID AND MAP
#### INPUT: GRIDPOS CANDIDATE. HANDLES EVERYTHING
func putOnGridAndMap(object:Node, gridPos:Vector2i) -> bool:
	
	#### PLACE DIRECTLY ON TILE
	if is_tile_empty(gridPos):
		print("Spawned at the original position")
		object.gridPosition = gridPos
	#### TRY PLACING IN RANDOM NEARBY LOCATION
	else:
		print("Spawned near the origin position")
		object.gridPosition = findEmptyTileInRange(gridPos)	
	
	matchPositionToGridPos(object)
	
	
	#### RETURN BOOL TO INDICATE IF SUMMON ETC. WAS SUCCESSFUL
	if object.gridPosition == Vector2i(999,999):
		prints("FAIL - Spawned: ", object, " at ", object.gridPosition)
		return false
		
	prints("Spawned: ", object, " at ", object.gridPosition)
	return true



func matchPositionToGridPos(object:Node):
	placeGridObjectOnMap(object, object.gridPosition)



func placeGridObjectOnMap(object:Node, gridPos:Vector2i):
	
	object.position = (gridPos * 32) + Vector2i(16,16)


func placeObjectOnTileOrNearbyFree(object:Node, gridPos:Vector2i):
	if is_tile_empty(gridPos):
		pass
		


func showTileInfo(grid_pos: Vector2i):
	pass


	
#### GO THROUGH EVERY TILEMAP, EQUALIZE THEIR ORIGIN POSITIONS
#### IF A WALL IS IN THE TILE, RETURN FALSE	
func is_tile_empty(grid_pos: Vector2i) -> bool:
	
	if world.isOverworld:
		return true
	
	#### CHECK IF WALL OR VOID TILE BLOCKS THE TILE
	match getTileValue(grid_pos):
		1,2:
			return false
	
	#### ELSE, DOES CREATURE BLOCK IT		
	for creature in world.getCreatures():
		if grid_pos == creature.gridPosition:
			return false
			
	#### TILE IS EMPTY
	return true
	
	
	
#### GET ALL ROOMS IN THE CURRENT WORLD STATE
#### STORE EACH WALLS-TYPE TILEMAP AND ITS ROOM'S META POSITION IN A DICT	
func createRoomsDictionary(rooms: Array):

	var wallsDict := {}
	var floorDict := {}
	
	for room in roomsList:
		var originGridPos = room.originGridPos	
		for tilem in room.get_node("Tiles").get_children():
			if tilem.is_in_group("walltiles"):
				wallsDict[tilem] = originGridPos
			elif tilem.is_in_group("floortiles"):
				floorDict[tilem] = originGridPos
	
	wallTilemapsDict = wallsDict
	floorTilemapsDict = floorDict
	
	
	wallTiles = getAllDictionaryTiles(wallTilemapsDict)
	floorTiles = getAllDictionaryTiles(floorTilemapsDict)			
	#return [wallsDict, floorDict]
	return []

	
func getAllDictionaryTiles(dictionary) -> Array:
	
	var cells := []
	for tilemap: TileMapLayer in dictionary:
		var myOriginPos = dictionary[tilemap]
		var myCells = tilemap.get_used_cells()
		var myC2 = []
		for ce in myCells:
			myC2.append(ce + myOriginPos)
			#prints(ce, myOriginPos)
		
		cells.append_array(myC2)
	
	return cells

	
	
func getWallAndFloorTiles() -> Array:
	
	var cells := []
	
	for tile in wallTiles:
		cells.append(tile)
	for tile in floorTiles:
		cells.append(tile)
	return cells
	
	

func createVoidTiles(voidTilemap:TileMapLayer):
	
	#### MAKE SURE PATHS' AREA IS ALSO IN REGIONTILES
	for tile in world.pathTurns:
		for tile2 in getCoordsInRange(tile,20):
			if not tile2 in regionTiles:
				regionTiles.append(tile2)
	
			
	for coord in regionTiles:
		
		if coord in wallTiles:
			voidTilemap.set_cell(coord, 2, Vector2i(0,0))	
						
		elif coord in world.pathTiles or coord in floorTiles:
			voidTilemap.set_cell(coord, -1, Vector2i(0,0))
		else:
			voidTiles.append(coord)
			voidTilemap.set_cell(coord, 1, Vector2i(0,0))
		
	return []
		
		
		
#### VALUES:
#### -1: Empty  |  1:Void  |  2:Walls
func getTileValue(coord) -> int:
	
	#var gridPos = voidTilemap.local_to_map(coord)
	return voidTilemap.get_cell_source_id(coord)

	
	
func getCreatureTiles() -> Array:
	
	var creaturePositions := []
	for creature in world.getCreatures():
		creaturePositions.append(creature.gridPosition)
		
	return creaturePositions



func getGridDistance(object1:Node, object2:Node) -> int:
	
	var distanceX = abs(object1.gridPosition.x - object2.gridPosition.x)
	var distanceY = abs(object1.gridPosition.y - object2.gridPosition.y)
	return max(distanceX, distanceY)


func getGridDistanceOfCoords(coord1:Vector2i, coord2:Vector2i):
	var distanceX = abs(coord1.x - coord2.x)
	var distanceY = abs(coord1.y - coord2.y)
	return max(distanceX, distanceY)


func getAdjacentCreatures(actor) -> Array:
	
	var creatures := []
	var adjacentCoords:Array = getCoordsInRange(actor.gridPosition, 1)
	
	for creature in world.getCreatures():
		if creature.gridPosition in adjacentCoords and creature != actor:
			creatures.append(creature)	
				
	return creatures
	


func getCoordsInRange(gridPos:Vector2i, distance:int) -> Array:
	
	var vectors := []
	for x in range(gridPos.x - distance, gridPos.x + distance + 1):
		for y in range(gridPos.y - distance, gridPos.y + distance + 1):
			vectors.append(Vector2i(x, y) )	
	return vectors



func findEmptyTileInRange(startingPos:Vector2i):
	var dirs = [Vector2i.UP,Vector2i.DOWN,Vector2i.RIGHT,Vector2i.LEFT,
	Vector2i(1,1),Vector2i(-1,-1),Vector2i(1,-1),Vector2i(-1,1)] 
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var emptyTiles:Array = getEmptyTilesInRange(startingPos)
	var randIndex:int = rng.randi_range(1,emptyTiles.size())
	
	if emptyTiles.is_empty():
		return Vector2i(999,999)
	return emptyTiles[randIndex - 1]
	
	

func getEmptyTilesInRange(startPos:Vector2i):
	
	var positions:Array = getCoordsInRange(startPos,3)
	var emptyTiles := []
	
	for pos in positions:
		if getTileValue(pos) == -1:
			if not pos in getCreatureTiles():
				emptyTiles.append(pos)
	return emptyTiles
