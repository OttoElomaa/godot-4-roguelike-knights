extends Node2D


@export var isOverworld := true

var game:Node = null
#@onready var player := $Creatures/PlayerKnight
@onready var player:Node = null

@onready var ui := $UI
@onready var startButton := $UI/MarginContainer/StartButton

var PlayerScene :PackedScene = load("res://Creatures/PlayerKnight.tscn")

var isMapKilled := false

var grid:Node:
	get:
		return $Grid
		

func setup(game):
	self.game = game
	player = PlayerScene.instantiate()
	$Creatures.add_child(player)
	prints("player at start of game: ", player, player.creatureName)
	
	player.playerSetup(self, true) #### TRUE = IS OVERWORLD
	$Grid.setup(self)
	
	for dungeonIcon in $Dungeons.get_children():
		dungeonIcon.setup(self)
	
	for characterIcon in $UI/Vbox/Chars_Hbox.get_children():
		characterIcon.setup(self)
		
	#setStartButtonVisible(false)



func passTurn():
	
	for dungeonIcon in $Dungeons.get_children():
		dungeonIcon.passTurn(player)


func startGameFromPlayerScene(playerPacked:PackedScene):
	game.startGame(playerPacked)
	

func startGame():
	game.startGame(PlayerScene)
	


func hideFunc():
	self.hide()
	$UI.hide()



#func setStartButtonVisible(show:bool):
	#if show:
		#startButton.show()
	#else:
		#startButton.hide()
