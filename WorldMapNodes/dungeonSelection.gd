extends Node2D


var game:Node = null

@onready var stageLabel := $UI/InfoMargin/FloorInfo/Margin/VBox/StageLabel


func setup(game:Node):
	self.game = game
	
	stageLabel.text = "You've reached Stage %d of the journey" % ProgressData.currentWorldStage
	
	for dungeonIcon in $UI/DungeonsPanel/Margin/Vbox/Dungeons_Hbox.get_children():
		dungeonIcon.setup(game, self)
