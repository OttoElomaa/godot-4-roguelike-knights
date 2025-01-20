extends CanvasLayer


@onready var stateLabel = $MainMargin/LookPanel/Margin/Hbox/StateLabel

@onready var lookLabel = $MainMargin/LookPanel/Margin/Hbox/LookLabel
@onready var lookLabel2 = $MainMargin/LookPanel/Margin/Hbox/LookLabel2







func updateStateLabel(isLook):
	if isLook:
		stateLabel.text = "Input State = Look"
	else:
		stateLabel.text = "Input State = Explore"


func showLookInfo(game, lookTool):
	
		lookLabel.text = str(lookTool.gridPosition.x) + ", " + str(lookTool.gridPosition.y)
	
		#### OPTION 2.1: A WALL TILE
		if not game.getGrid().is_tile_empty(lookTool.gridPosition):
			lookLabel2.text = "It's a wall."
			return
		
		else:
			var creatures : Array = game.getCreatures()
			#### OPTION 2.2.1: A CREATURE
			for creature in creatures:
				if lookTool.gridPosition == creature.gridPosition:
					lookLabel2.text = "It's a creature called " + creature.creatureName
					return
			#### OPTION 2.2.2: EMPTY TILE
			lookLabel2.text = "It's an open space."


func _on_button_pressed() -> void:
	
	var game = get_parent()
	game.startGame()
