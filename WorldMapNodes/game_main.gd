extends Node2D



var World:PackedScene = load("res://WorldNodes/world.tscn")
var DungeonSelect:PackedScene = load("res://WorldMapNodes/dungeonSelection.tscn")

var DebugWorld:PackedScene = load("res://WorldNodes/DebugWorld.tscn")

var storedPlayer:Node = null
var currentDungeon:Node = null

var currentDungeonInfo:Object = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	ProgressData.currentWorldStage = 1
	
	$CharacterCreation.setup(self)
	
	$LilWorld/AStarGridNode.setup(self)
	for x in range(-100,100):
		for y in range(-100,100):
			$LilWorld/GroundTiles.set_cell(Vector2i(x,y), 0, Vector2i.ZERO)
			
	var walkerRoomPositions = $LilWorld/Walker.walkMiniworld(50)
	generatePath(walkerRoomPositions)
	

	
func startGame():
	
	ProgressData.maxDungeonFloor = currentDungeonInfo.floorsCount
	ProgressData.dungeonFloorLevel = 0
	
	$LilWorld.queue_free()
	generateNewLevel(storedPlayer)
	
	

func startDungeonSelect(playerPacked:PackedScene):
	
	storedPlayer = playerPacked.instantiate()
	$CharacterCreation.queue_free()
	
	var dungeonSelect = DungeonSelect.instantiate()
	add_child(dungeonSelect)
	dungeonSelect.setup(self)
	
	
	#startGame(playerPacked)

func startGameFromDungeonIcon(dungeonInfo:Object, isDebugMap:bool):
	#### SET INFO OF CURRENT DUNGEON
	currentDungeonInfo = dungeonInfo
	
	#### START GAME
	if isDebugMap:
		loadDebugLevel()
	else:
		startGame()

	

func generateNewLevel(player:Node):
	
	var world = World.instantiate()
	add_child(world)
	
	ProgressData.dungeonFloorLevel += 1
	
	await get_tree().process_frame
	await get_tree().process_frame
	world.startGame(self, player, currentDungeonInfo)


func loadDebugLevel():
	
	$LilWorld.queue_free()
	var world = DebugWorld.instantiate()
	add_child(world)
	world.startDebugLevel(self, storedPlayer, currentDungeonInfo)



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
