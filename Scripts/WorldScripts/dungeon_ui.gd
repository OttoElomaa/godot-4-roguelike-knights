extends CanvasLayer


@onready var stateLabel := $LookMargin/LookPanel/Margin/Hbox/StateLabel

@onready var lookLabel := $LookMargin/LookPanel/Margin/Hbox/LookLabel
@onready var lookLabel2 := $LookMargin/LookPanel/Margin/Hbox/LookLabel2

@onready var skillBar := $Margin/SkillBar
@onready var combatLog := $Margin2/LogPanel/MarginContainer/CombatLog




func displayPlayerSkills(player):
	
	var boxes:Array = skillBar.get_children()
	var skills:Array = player.getSkills()
	
	if skills.is_empty():
		return
	#### SET EACH SKILL'S ICON IN SKILL BAR	
	for i in range(skills.size()):
		boxes[i].setup(skills[i])
		
		



func updateStateLabel(isLook):
	if isLook:
		stateLabel.text = "Input State = Look"
	else:
		stateLabel.text = "Input State = Explore"



func showMouseLookCreature(creature:Node):
	lookLabel.text = "%d, %d" % [creature.gridPosition.x, creature.gridPosition.y]
	lookLabel2.text = "It's a creature called " + creature.creatureName

func showLookInfo(game, lookTool):
	
	var grid = game.getGrid()
	lookLabel.text = "%d, %d" % [lookTool.gridPosition.x, lookTool.gridPosition.y] 
	
	var pos = lookTool.gridPosition
	
	#### OPTION 2.1: A WALL TILE
	#if not grid.is_tile_empty(lookTool.gridPosition):
	if grid.getTileValue(pos) == 2:
		lookLabel2.text = "It's a wall."
		return
	elif grid.getTileValue(pos) == 1:
		lookLabel2.text = "It's an impassable void."
		return
	
	else:
		var creatures : Array = game.getCreatures()
		#### OPTION 2.2.1: A CREATURE
		for creature in creatures:
			if pos == creature.gridPosition:
				lookLabel2.text = "It's a creature called " + creature.creatureName
				return
		#### OPTION 2.2.2: EMPTY TILE
		if grid.getTileValue(pos) == -1:
			lookLabel2.text = "It's an open space."
			return
			
		lookLabel2.text = "This tile is bugged?"
			
			
			
func addMessage(text:String, color:Color) -> void:
	
	combatLog.addMessage(text, color)


func toggleLoadingScreen(visible:bool):
	if visible:
		$LoadingImage.show()
	else:
		$LoadingImage.hide()
