extends Node2D


@export var isOverworld := true

var game:Node = null
@onready var player := $Creatures/Player
@onready var ui := $UI


var grid:Node:
	get:
		return $Grid
		

func setup(game):
	self.game = game
	player.playerSetup(self, true) #### TRUE = IS OVERWORLD
	$Grid.setup(self)
	
	for dungeonIcon in $Dungeons.get_children():
		dungeonIcon.setup(self)
		
	setStartButtonVisible(false)



func passTurn():
	
	for dungeonIcon in $Dungeons.get_children():
		dungeonIcon.passTurn(player)




func startGame():
	game.startGame()
	

func _on_button_pressed() -> void:
	
	#self.game = get_parent()
	game.startGame()
	
	
	
func hideFunc():
	self.hide()
	$UI.hide()



func setStartButtonVisible(show:bool):
	if show:
		$UI/MarginContainer/StartButton.show()
	else:
		$UI/MarginContainer/StartButton.hide()
