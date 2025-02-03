extends Node2D



var World = load("res://Scenes/world.tscn")

var storedPlayer:Node = null
var currentDungeon:Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$WorldMap.setup(self)
	
	#$World.hide()
	$WorldMap.show()
	

	
func startGame(playerScene:PackedScene):
	
	storedPlayer = playerScene.instantiate()
	generateNewLevel()
	
	
	#$WorldMap.hideFunc()
	$WorldMap.queue_free()
	
	

func generateNewLevel():
	
	var world = World.instantiate()
	add_child(world)
	
	await get_tree().process_frame
	await get_tree().process_frame
	world.startGame(self, storedPlayer)



func getUi():
	return $UI
