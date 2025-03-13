extends Node2D


var game:Node = null

func setup(game:Node):
	self.game = game
	
	for dungeonIcon in $UI/Vbox/Dungeons_Hbox.get_children():
		dungeonIcon.setup(game, self)
