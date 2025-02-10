extends CanvasLayer


@onready var stateLabel := $LookMargin/VBox/LookPanel/Margin/LookHbox/StateLabel

@onready var lookLabel := $LookMargin/VBox/LookPanel/Margin/LookHbox/LookLabel
@onready var nameLabel := $LookMargin/VBox/LookPanel/Margin/LookHbox/NameText

@onready var floorLabel := $LookMargin/VBox/FloorInfo/Margin/Hbox/FloorLabel
@onready var goldLabel := $LookMargin/VBox/FloorInfo/Margin/Hbox/GoldLabel
@onready var enemiesLabel := $LookMargin/VBox/FloorInfo/Margin/Hbox/EnemiesLabel

@onready var skillBar := $Margin/SkillBar
@onready var combatLog := $Margin2/LogPanel/MarginContainer/CombatLog

var LogDoubleRow:PackedScene = load("res://Scenes/UI/logDoubleRow.tscn")
var LogMessage = load("res://Scenes/UI/BasicLogMessage.tscn")

var initialMessage:Node = null


func displayPlayerSkills(player):
	
	var boxes:Array = skillBar.get_children()
	var skills:Array = player.getSkills()
	
	if skills.is_empty():
		return
	#### SET EACH SKILL'S ICON IN SKILL BAR	
	for i in range(skills.size()):
		boxes[i].setup(skills[i])
	

func updateVisualsOnTurn():
	updateProgressLabels()
	
	for box in skillBar.get_children():
		if box.skill != null:
			box.updateVisuals()	



func updateStateLabel(isLook):
	if isLook:
		stateLabel.text = "Input State = Look"
	else:
		stateLabel.text = "Input State = Explore"


func updateProgressLabels():
	goldLabel.text = "Gold: %d" % ProgressData.gold
	enemiesLabel.text = "Enemies killed: %d" % ProgressData.enemiesKilled



func showMouseLookCreature(creature:Node):
	var labelsBox := $LookMargin/VBox/LookPanel/Margin/LookHbox
	
	lookLabel.text = "%d, %d" % [creature.gridPosition.x, creature.gridPosition.y]
	nameLabel.text = "It's a creature called %s" % creature.creatureName
	
	labelsBox.get_node("HealthLabel").text = "Health: %d" % creature.stats.health.current
	labelsBox.get_node("ArmorLabel").text = "Armor: %d" % creature.stats.armor.current
	labelsBox.get_node("BlockLabel").text = "Armor: %d" % creature.stats.block.current
	labelsBox.get_node("EvasionLabel").text = "Armor: %d" % creature.stats.evasion.current


func showLookInfo(game, lookTool):
	
	var grid = game.getGrid()
	lookLabel.text = "%d, %d" % [lookTool.gridPosition.x, lookTool.gridPosition.y] 
	
	var pos = lookTool.gridPosition
	
	#### OPTION 2.1: A WALL TILE
	#if not grid.is_tile_empty(lookTool.gridPosition):
	if grid.getTileValue(pos) == 2:
		nameLabel.text = "It's a wall."
		return
	elif grid.getTileValue(pos) == 1:
		nameLabel.text = "It's an impassable void."
		return
	
	else:
		var creatures : Array = game.getCreatures()
		#### OPTION 2.2.1: A CREATURE
		for creature in creatures:
			if pos == creature.gridPosition:
				nameLabel.text = "It's a creature called " + creature.creatureName
				return
		#### OPTION 2.2.2: EMPTY TILE
		if grid.getTileValue(pos) == -1:
			nameLabel.text = "It's an open space."
			return
			
		nameLabel.text = "This tile is bugged?"
			
			
			
func addMessage(text:String, color:Color) -> void:
	
	combatLog.addMessage(text, color)



func saveInitialMessage(text:String, color:Color) -> void:

	initialMessage = LogMessage.instantiate()
	initialMessage.text = text
	initialMessage.color = color


func addLogRow(text:String, color:Color) -> void:
	
	
	var item1:Node = initialMessage
	
	var item2:Node = LogMessage.instantiate()
	item2.text = text
	item2.color = color
	
	var row = LogDoubleRow.instantiate()
	row.setupRowFromArray(self, item1, item2)
	


func addLogItemHelp(item:Node):
	combatLog.addItem(item)


func clearInitialRow():
	addLogItemHelp(initialMessage)


func toggleLoadingScreen(visible:bool):
	if visible:
		$LoadingImage.show()
	else:
		$LoadingImage.hide()
