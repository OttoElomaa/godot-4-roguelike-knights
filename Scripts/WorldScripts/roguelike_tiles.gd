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

var voidTilemap:TileMapLayer = null


# Called when the node enters the scene tree for the first time.
func setup(world: Node):
	
	self.world = world
	
	if world.isOverworld:
		return
	
	#### SETUP WALLS AND FLOORS TILE LISTS HERE
	roomsList = world.getRooms()
	createRoomsDictionary(roomsList)
	
	#wallTilemapsDict = dicts[0]
	#floorTilemapsDict = dicts[1]
	
	nonVoidTiles = getWallAndFloorTiles()
	
	#### STORE TILE INFO IN A TILEMAP AT WORLD
	voidTilemap = world.voidTilemap
	createVoidTiles(voidTilemap)
	
	for coord in wallTiles:
		voidTilemap.set_cell(coord, 2, Vector2i(0,0))
	


func overworldSetup(worldMap:Node):
	self.world = worldMap



func placeGridObjectOnMap(object:Node, gridPos:Vector2i):
	
	object.position = (gridPos * 32) + Vector2i(16,16)



func grid_to_world(grid_pos: Vector2i) -> Vector2i:
	
	var halfVector := Vector2i(tileSize/2, tileSize/2)
	var world_pos: Vector2i = grid_pos * tileSize + halfVector
	return world_pos



func world_to_grid(world_pos: Vector2i) -> Vector2i:
	var grid_pos: Vector2i = world_pos / tileSize
	return grid_pos
	


func showTileInfo(grid_pos: Vector2i):
	pass


	
#### GO THROUGH EVERY TILEMAP, EQUALIZE THEIR ORIGIN POSITIONS
#### IF A WALL IS IN THE TILE, RETURN FALSE	
func is_tile_empty(grid_pos: Vector2i) -> bool:
	
	if world.isOverworld:
		return true
	
	var targetTileValue = getTileValue(grid_pos)
	match targetTileValue:
		1,2:
			return false
	return true	
	
	#if grid_pos in wallTiles:
		#return false
	#if not grid_pos in floorTiles:
		#return false
	
	

	
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
	
	for x in range(-200,200):
		for y in range(-200,200):
			var coord = Vector2i(x,y)
			if coord in floorTiles or coord in wallTiles:
				pass
			else:
				voidTiles.append(coord)
				voidTilemap.set_cell(coord, 1, Vector2i(0,0))
		

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

	
