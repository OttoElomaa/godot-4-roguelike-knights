extends Node2D



var Orc = load("res://Scenes/Creatures/Orc.tscn")
var Slime = load("res://Scenes/Creatures/Slime.tscn")


var game: Node = null

var player: Node = null
var grid: Node = null

var playerGridPos := Vector2i.ZERO

var originGridPos := Vector2i.ZERO
var metaGridPos := Vector2i.ZERO



func setup(game: Node):
	self.game = game
	grid = game.getGrid()
	
	
func placeOnMetaGrid(metaPos: Vector2i):
	
	metaGridPos = metaPos
	originGridPos = metaGridPos * 20
	position += Vector2(originGridPos) * 32
	
	
	
	
func startGameAtRoom(setPlayer) -> void:
	
	var playerStart = $Utilities/PlayerStart
	var playerNewPos = $Tiles/FloorTiles2.local_to_map(playerStart.position)
	
	
	playerNewPos += originGridPos
	
	player = setPlayer
	
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
	
	var rng = randi_range(1,2)
	match rng:
		1:
			return Orc.instantiate()
		2:
			return Slime.instantiate()
			
	return Orc.instantiate()	



func randomizeTileGraphics():
	
	#### THEME SETTER: CASTLE, CAVE ETC
	var rng = randi_range(0,2)
	
	for tilemap:TileMapLayer in $Tiles.get_children():
		
		if tilemap.is_in_group("debugtiles"):
			for tilePos:Vector2i in tilemap.get_used_cells():
				tilemap.set_cell(tilePos, 82, Vector2i(0,0))
				
				
		elif tilemap.is_in_group("cluttertiles"):
			for tilePos:Vector2i in tilemap.get_used_cells():
				var blankSpaceRng = randi_range(1,5)
				if blankSpaceRng > 2:
					#### VARIANT SETTER (Y POS IN ATLAS)
					var rngY = randi_range(0,2)
					tilemap.set_cell(tilePos, 0, Vector2i(rng,rngY))
				else:
					tilemap.set_cell(tilePos, 83, Vector2i(0,0)) #### BLANK TILE
		
			
		else:
			for tilePos:Vector2i in tilemap.get_used_cells():
				tilemap.set_cell(tilePos, tilemap.get_cell_source_id(tilePos), Vector2i(rng, 0) )



	
	
	
	
