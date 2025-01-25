extends Node2D



var World = load("res://Scenes/world.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$WorldMap.setup(self)
	
	#$World.hide()
	$WorldMap.show()
	

	
func startGame(playerScene:PackedScene):
	
	
	
	var world = World.instantiate()
	add_child(world)
	world.startGame(self, playerScene)
	
	#$WorldMap.hideFunc()
	$WorldMap.queue_free()
	
	

func getUi():
	return $UI
