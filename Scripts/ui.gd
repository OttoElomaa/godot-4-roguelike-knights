extends CanvasLayer


@onready var stateLabel := $MainMargin/LookPanel/Margin/Hbox/StateLabel

@onready var lookLabel := $MainMargin/LookPanel/Margin/Hbox/LookLabel
@onready var lookLabel2 := $MainMargin/LookPanel/Margin/Hbox/LookLabel2

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
			
			
			
func addMessage(text:String) -> void:
	
	combatLog.addMessage(text)
