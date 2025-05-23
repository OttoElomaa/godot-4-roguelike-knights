extends Node2D


var gridPosition := Vector2i.ZERO
var world:Node = null
@onready var startButton := $CanvasLayer/StartButton


func setup(world):
	
	self.world = world
	
	gridPosition = GridTools.localToGrid(self.position)
	position = GridTools.gridToWorld(gridPosition)
	
	startButton.hide()
	prints("dungeon pos: ", gridPosition)
	
	
func passTurn(player:Node):
	
	print("passing overworld turn")
	if self.gridPosition == player.gridPosition:
		print("Dungeon reached")
		#world.setStartButtonVisible(true)
		startButton.show()
	else:
		#world.setStartButtonVisible(false)
		startButton.hide()


func _on_button_pressed() -> void:
	
	print("Dungeon button pressed")
	world.startGame()
