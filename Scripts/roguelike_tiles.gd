extends Node


var tileSize := 32

var game: Node = null
var roomsList := []
var wallTilemapsDict := {}

# Called when the node enters the scene tree for the first time.
func setup(game: Node):
	
	self.game = game
	roomsList = game.getRooms()
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
	for creature in game.getCreatures():
		creaturePositions.append(creature.gridPosition)
		
	return creaturePositions
	
