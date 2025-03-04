extends Node2D



var World = load("res://WorldNodes/world.tscn")

var storedPlayer:Node = null
var currentDungeon:Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$WorldMap.setup(self)
	
	#$World.hide()
	$WorldMap.show()
	

	
func startGame(playerScene:PackedScene):
	
	storedPlayer = playerScene.instantiate()
	assert(storedPlayer, "WTF")
	generateNewLevel(storedPlayer)
	
	
	#$WorldMap.hideFunc()
	$WorldMap.queue_free()
	
	

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
