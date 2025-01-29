extends Node2D



var Orc = load("res://Scenes/Creatures/Orc.tscn")
var Slime = load("res://Scenes/Creatures/Slime.tscn")
var SkeletonArcher = load("res://Scenes/Creatures/SkeletonArcher.tscn")
var DarkHealer = load("res://Scenes/Creatures/DarkHealer.tscn")


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
	position += Vector2(originGridPos) * 32



func startGameAtRoom(setPlayer) -> void:
	
	var playerStart = $Utilities/PlayerStart
	var playerNewPos = $Tiles/FloorTiles2.local_to_map(playerStart.position)
	
	
	playerNewPos += originGridPos
	
	player.gridPosition = playerNewPos
	grid.placeGridObjectOnMap(player, playerNewPos)



func populateCreatures() -> Array:
	
	var creatures := []
	
	for start in $Utilities/CreatureSpawnPoints.get_children():
		var newCreature = createRandomCreature()
		newCreature.roomSetup(self)
		
		var newPos = $Tiles/FloorTiles2.local_to_map(start.position)
		var gridPos = newPos + originGridPos
		newCreature.gridPosition = gridPos
		
		grid.placeGridObjectOnMap(newCreature, gridPos)
		creatures.append(newCreature)
		
	return creatures


func createRandomCreature() -> Node:
	
	var rng = randi_range(1,4)
	match rng:
		1:
			return Orc.instantiate()
		2:
			return Slime.instantiate()
		3:
			return SkeletonArcher.instantiate()
		4:
			return DarkHealer.instantiate()
			
	return Orc.instantiate()	



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


func getStartPosition():
	var pos = $Utilities/Center.position
	return grid.world_to_grid(position + pos) 



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

	
	#for tilePos:Vector2i in utilTiles.get_used_cells():
		#utilTiles.set_cell(tilePos, -1)
		
	utilTiles.queue_free()
	$Tiles/Backdrop2.queue_free()
	
	
