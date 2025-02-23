extends Node2D



var game: Node = null

var player: Node = null
var grid: Node = null

@onready var floorTilemap = $Tiles/FloorTiles2
@onready var wallTilemap = $Tiles/WallTiles2

var playerGridPos := Vector2i.ZERO

var originGridPos := Vector2i.ZERO
var metaGridPos := Vector2i.ZERO

var globalRoomSize := 15


func setup(game: Node):
	self.game = game
	grid = game.grid
	player = game.player
	
	#$Tiles/Backdrop2.queue_free()
	
	
func placeOnMetaGrid(metaPos: Vector2i):
	
	metaGridPos = metaPos
	originGridPos = metaGridPos * globalRoomSize
	position += Vector2(originGridPos) * 32
	

func placeOnGrid(gridPos:Vector2i):	
	originGridPos = gridPos
	position = Vector2(originGridPos) * 32



func startGameAtRoom(setPlayer) -> void:
	
	var playerStart = $Utilities/PlayerStart
	var playerNewPos = $Tiles/FloorTiles2.local_to_map(playerStart.position)
	
	
	playerNewPos += originGridPos
	
	player.gridPosition = playerNewPos
	grid.placeGridObjectOnMap(player, playerNewPos)



func populateCreatures(world) -> Array:
	
	#### BOSS IS SPAWNED IN WORLD SCRIPT. NO OTHER ENEMIES IN BOSS ROOM
	if self == world.lastRoom:
		return []
	
	#### SPAWN AN ENEMY IN EACH START LOCATION
	var creatures := []
	
	for start in $Utilities/CreatureSpawnPoints.get_children():
		var newCreature = FileLoader.createRandomCreature()
		newCreature.setup(world)
		
		var newPos = $Tiles/FloorTiles2.local_to_map(start.position)
		var gridPos = newPos + originGridPos
		newCreature.gridPosition = gridPos
		
		grid.placeGridObjectOnMap(newCreature, gridPos)
		creatures.append(newCreature)
		
	return creatures




func setTileGraphics(setValue:int):
	
	#### THEME SETTER: CASTLE, CAVE ETC
	#var rng = randi_range(0,2)
	
	for tilemap:TileMapLayer in $Tiles.get_children():
		
		if tilemap.is_in_group("debugtiles"):
			for tilePos:Vector2i in tilemap.get_used_cells():
				tilemap.set_cell(tilePos, 82, Vector2i(0,0))
				
		#### RANDOMIZE SOME CLUTTER ITEMS LIKE PLANTS/BARRELS IN ROOM		
		elif tilemap.is_in_group("cluttertiles"):
			for tilePos:Vector2i in tilemap.get_used_cells():
				var blankSpaceRng = randi_range(1,5)
				if blankSpaceRng > 2:
					#### VARIANT SETTER (Y POS IN ATLAS)
					var rngY = randi_range(0,2)
					tilemap.set_cell(tilePos, 0, Vector2i(setValue,rngY))
				else:
					tilemap.set_cell(tilePos, 83, Vector2i(0,0)) #### BLANK TILE
		
		#### CHANGE "BIOME" BY SWITCHING ATLAS COORDINATES	
		else:
			for tilePos:Vector2i in tilemap.get_used_cells():
				tilemap.set_cell(tilePos, tilemap.get_cell_source_id(tilePos), Vector2i(setValue, 0) )
				


#### GET GLOBAL POSITION OF ROOM'S "CENTER" POSITION
#### USED MOSTLY FOR CONNECTING ROOMS WITH A PATH. ALSO PLACING EXIT
func getStartPosition():
	var pos = $Utilities/Center.position
	return GridTools.world_to_grid(position + pos) 


func getPlayerStartPos():
	var pos = $Utilities/PlayerStart.position
	return GridTools.world_to_grid(position + pos) 



func createOpenPathFromArray(path:Array):
	var utilTiles := $Tiles/UtilityTiles
	#var myPath := []
	#var coolTestArray := []
	
	for coord in path:
		var transformed = coord - Vector2i(originGridPos)
		
		#### CONVERT THEM INTO FLOOR TILES	
		var pos = Vector2i(transformed)
		if pos in $Tiles/WallTiles2.get_used_cells():
			if not pos in utilTiles.get_used_cells():
				$Tiles/WallTiles2.set_cell(transformed, -1)
	
			
	#### AFTER PUNCHING HOLES IN WALLS, MAKE ALL RELEVANT TILES LOOK LIKE WALL EDGES
	#### -1 = EMPTY TILE  |  22 = WALL EDGE ID			
	for wall in wallTilemap.get_used_cells():
		var vec = Vector2i(wall.x, wall.y + 1)
		var cellBelowId = wallTilemap.get_cell_source_id(vec)
		if cellBelowId == -1:
			
			match wallTilemap.get_cell_source_id(wall):
				21:
					wallTilemap.set_cell(wall, 22, Vector2i(0,0))
				23:
					wallTilemap.set_cell(wall, 24, Vector2i(0,0))
					
	
	finishRoomSetup()	
			
			

func finishRoomSetup():
	
	#### FOR UNPASSABLE VOID TILES CREATION, MAP THE ENTIRE AREA OF THE ROOM VIA BACKDROP LAYER
	for tilePos:Vector2i in $Tiles/Backdrop2.get_used_cells():
		var fixedPos = tilePos + originGridPos
		if not fixedPos in grid.regionTiles:
			grid.regionTiles.append(fixedPos)
	
	$Tiles/UtilityTiles.queue_free()
	$Tiles/Backdrop2.queue_free()
	
	
