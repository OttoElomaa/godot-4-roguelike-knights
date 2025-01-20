extends Node


var tileSize := 32

var world: Node = null
var roomsList := []
var wallTilemapsDict := {}

# Called when the node enters the scene tree for the first time.
func setup(world: Node):
	
	self.world = world
	roomsList = world.getRooms()
	wallTilemapsDict = createRoomsDictionary(roomsList)



func placeGridObjectOnMap(object:Node, gridPos:Vector2i):
	
	object.position = (gridPos * 32) + Vector2i(16,16)


func grid_to_world(grid_pos: Vector2i) -> Vector2i:
	var world_pos: Vector2i = grid_pos * tileSize
	return world_pos


func world_to_grid(world_pos: Vector2i) -> Vector2i:
	var grid_pos: Vector2i = world_pos / tileSize
	return grid_pos
	

func showTileInfo(grid_pos: Vector2i):
	pass


	
	
#### GO THROUGH EVERY TILEMAP, EQUALIZE THEIR ORIGIN POSITIONS
#### IF A WALL IS IN THE TILE, RETURN FALSE	
func is_tile_empty(grid_pos: Vector2i) -> bool:
	
	for tilemap: TileMapLayer in wallTilemapsDict:
		var myOriginPos = wallTilemapsDict[tilemap]
		var myGridPos = grid_pos - myOriginPos
		if tilemap.get_cell_source_id(myGridPos) != -1:
			return false		
	return true
	
#### GET ALL ROOMS IN THE CURRENT WORLD STATE
#### STORE EACH WALLS-TYPE TILEMAP AND ITS ROOM'S META POSITION IN A DICT	
func createRoomsDictionary(rooms: Array) -> Dictionary:

	var returnDict := {}
	for room in roomsList:
		var originGridPos = room.originGridPos	
		for tilem in room.get_node("Tiles").get_children():
			if tilem.is_in_group("walltiles"):
				returnDict[tilem] = originGridPos
	return returnDict


func getAllWallTiles() -> Array:
	
	var cells := []
	for tilemap: TileMapLayer in wallTilemapsDict:
		var myOriginPos = wallTilemapsDict[tilemap]
		var myCells = tilemap.get_used_cells()
		var myC2 = []
		for ce in myCells:
			myC2.append(ce + myOriginPos)
			#prints(ce, myOriginPos)
		
		cells.append_array(myC2)
	
	return cells
	
func getCreatureTiles() -> Array:
	
	var creaturePositions := []
	for creature in world.getCreatures():
		creaturePositions.append(creature.gridPosition)
		
	return creaturePositions


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

	
#if abs(creature.gridPosition.x - actor.gridPosition.x) <= 1:
			#if abs(creature.gridPosition.y - actor.gridPosition.y) <= 1:
				#if creature != actor:	
