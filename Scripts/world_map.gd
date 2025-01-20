extends Node2D


var game:Node = null


func setup(game):
	self.game = game


func _on_button_pressed() -> void:
	
	#self.game = get_parent()
	game.startGame()
	
	
	
func hideFunc():
	self.hide()
	$UI.hide()
