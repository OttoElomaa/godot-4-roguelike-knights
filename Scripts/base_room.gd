extends Node2D



var game: Node = null

var player: Node = null
var grid: Node = null

var playerGridPos := Vector2i.ZERO

var originGridPos := Vector2i.ZERO
var metaGridPos := Vector2i.ZERO

var globalRoomSize := 15


func setup(game: Node):
	self.game = game
	grid = game.getGrid()
	player = game.getPlayer()
	
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
	
	var creatures := []
	
	for start in $Utilities/CreatureSpawnPoints.get_children():
		var newCreature = FileLoader.createRandomCreature()
		newCreature.roomSetup(self, world)
		
		var newPos = $Tiles/FloorTiles2.local_to_map(start.position)
		var gridPos = newPos + originGridPos
		newCreature.gridPosition = gridPos
		
		grid.placeGridObjectOnMap(newCreature, gridPos)
		creatures.append(newCreature)
		
	return creatures




func randomizeTileGraphics():
	
	#### THEME SETTER: CASTLE, CAVE ETC
	var rng = randi_range(0,2)
	
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
					tilemap.set_cell(tilePos, 0, Vector2i(rng,rngY))
				else:
					tilemap.set_cell(tilePos, 83, Vector2i(0,0)) #### BLANK TILE
		
		#### CHANGE "BIOME" BY SWITCHING ATLAS COORDINATES	
		else:
			for tilePos:Vector2i in tilemap.get_used_cells():
				tilemap.set_cell(tilePos, tilemap.get_cell_source_id(tilePos), Vector2i(rng, 0) )
				


#### GET GLOBAL POSITION OF ROOM'S "CENTER" POSITION
#### USED MOSTLY FOR CONNECTING ROOMS WITH A PATH. ALSO PLACING EXIT
func getStartPosition():
	var pos = $Utilities/Center.position
	return GridTools.world_to_grid(position + pos) 



func generateOpenPath(paths:Array):
	
	var utilTiles := $Tiles/UtilityTiles
	#var myPath := []
	#var coolTestArray := []
	
	for path in paths:
		for coord in path:
			var transformed = coord - Vector2(originGridPos) + Vector2(16,16)
			
			#### CONVERT THEM INTO FLOOR TILES	
			#assert(transformed in utilTiles.get_used_cells(), "BRUH")
			var pos = Vector2i(transformed)
			if pos in $Tiles/Backdrop2.get_used_cells():
				if not pos in utilTiles.get_used_cells():
					#myPath = path
					$Tiles/WallTiles2.set_cell(transformed, -1)
					$Tiles/PathTiles.set_cell(transformed, 6, Vector2(0,0))
				
	#prints("test pathtiles: ",coolTestArray)
	#prints("test util bordertiles: ", utilTiles.get_used_cells())

	
	#### SET SOME NICE WALLS AROUND THE PATH - NOT ESSENTIAL

	#### FOR UNPASSABLE VOID TILES CREATION, MAP THE ENTIRE AREA OF THE ROOM VIA BACKDROP LAYER
	for tilePos:Vector2i in $Tiles/Backdrop2.get_used_cells():
		var fixedPos = tilePos + originGridPos
		if not fixedPos in grid.regionTiles:
			grid.regionTiles.append(fixedPos)
	
		
	utilTiles.queue_free()
	$Tiles/Backdrop2.queue_free()
	
	
