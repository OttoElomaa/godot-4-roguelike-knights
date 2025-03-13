extends Node2D



var World:PackedScene = load("res://WorldNodes/world.tscn")

var DungeonSelect:PackedScene = load("res://WorldMapNodes/dungeonSelection.tscn")

var storedPlayer:Node = null
var currentDungeon:Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for characterIcon in $CharacterCreation/UI/Vbox/Chars_Hbox.get_children():
		characterIcon.setup(self)
	

	
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


func getUi():
	return $UI
