extends Node2D








# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$WorldMap.setup(self)
	
	$World.hide()
	$WorldMap.show()
	

	
func startGame():
	
	$WorldMap.hideFunc()
	$World.show()
	
	$World.startGame(self)
	
	

func getUi():
	return $UI
