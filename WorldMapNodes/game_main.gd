extends Node2D



var World:PackedScene = load("res://WorldNodes/world.tscn")

var DungeonSelect:PackedScene = load("res://WorldMapNodes/dungeonSelection.tscn")

var storedPlayer:Node = null
var currentDungeon:Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for characterIcon in $CharacterCreation/UI/Vbox/Chars_Hbox.get_children():
		characterIcon.setup(self)
	
	$LilWorld/AStarGridNode.setup(self)
	for x in range(-100,100):
		for y in range(-100,100):
			$LilWorld/GroundTiles.set_cell(Vector2i(x,y), 0, Vector2i.ZERO)
			
	var walkerRoomPositions = $LilWorld/Walker.walkMiniworld(50)
	generatePath(walkerRoomPositions)
	

	
func startGame():
	
	#storedPlayer = playerScene.instantiate()
	generateNewLevel(storedPlayer)
	
	

func startGameFromPlayerScene(playerPacked:PackedScene):
	
	storedPlayer = playerPacked.instantiate()
	$CharacterCreation.queue_free()
	
	var dungeonSelect = DungeonSelect.instantiate()
	dungeonSelect.setup(self)
	add_child(dungeonSelect)
	
	#startGame(playerPacked)

func startGameFromDungeonIcon():
	startGame()

	

func generateNewLevel(player:Node):
	
	var world = World.instantiate()
	add_child(world)
	
	await get_tree().process_frame
	await get_tree().process_frame
	world.startGame(self, player)



func showDeathMessage():
	$CanvasLayer/DeathMessage.show()



func generatePath(dungeonPath:Array) -> Array:
	
	var allPathTiles := []
	
	#### CREATE ASTAR PATHS BETWEEN EACH OF THEM
	var paths := []
	for i in range(1, dungeonPath.size()):
		var prev = dungeonPath[i-1].gridPosition
		var curr = dungeonPath[i].gridPosition
		paths.append($LilWorld/AStarGridNode.createPathManhattan(prev, curr))
	
	#### CONVERT THEM TO GRID COORDINATES
	for path in paths:
		for coord in path:
			#### CONVERSION FROM REGULAR COORDINATES
			var converted = coord / 32 - Vector2(16.5, 16.5)
			$LilWorld/GroundTiles.set_cell(converted, 1, Vector2i.ZERO)
			
	#prints("Path by aStar node: ", allPathTiles )
	return allPathTiles


func getUi():
	return $UI
