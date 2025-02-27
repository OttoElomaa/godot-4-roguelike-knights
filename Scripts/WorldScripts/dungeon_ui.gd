extends CanvasLayer


@onready var floorLabel := $LookMargin/VBox/FloorInfo/Margin/Hbox/FloorLabel
@onready var goldLabel := $LookMargin/VBox/FloorInfo/Margin/Hbox/GoldLabel
@onready var enemiesLabel := $LookMargin/VBox/FloorInfo/Margin/Hbox/EnemiesLabel

@onready var lookPanel := $LookMargin/VBox/LookPanel
@onready var playerPanel := $LookMargin/VBox/PlayerPanel

@onready var skillBar := $BottomPanel/Hbox/SkillsMargin/SkillBar
@onready var combatLog := $BottomPanel/Hbox/LogMargin/LogPanel/MarginContainer/CombatLog

var LogDoubleRow:PackedScene = load("res://Scenes/UI/logDoubleRow.tscn")
var LogMessage = load("res://Scenes/UI/BasicLogMessage.tscn")

var initialMessage:Node = null



func setup(world):
	playerPanel.setupPlayerView(world.player)



func displayPlayerSkills(player):
	
	var boxes:Array = skillBar.get_children()
	var skills:Array = player.getSkills()
	
	if skills.is_empty():
		return
	#### SET EACH SKILL'S ICON IN SKILL BAR	
	for i in range(skills.size()):
		boxes[i].setup(skills[i], i)
	


func updateVisualsOnTurn():
	playerPanel.updatePlayerStats()
	updateProgressLabels()
	
	for box in skillBar.get_children():
		if box.skill != null:
			box.updateVisuals()	



func updateProgressLabels():
	goldLabel.text = "Gold: %d" % ProgressData.gold
	enemiesLabel.text = "Enemies killed: %d" % ProgressData.enemiesKilled



func showTargetCreature(creature:Node):
	if not is_instance_valid(creature):
		return
	if creature.is_queued_for_deletion():
		return
	lookPanel.showTargetCreature(creature)


func showMouseLookCreature(creature:Node):
	lookPanel.showMouseLookCreature(creature)


func showLookInfo(game:Node, lookTool:Node):
	
	lookPanel.showLookInfo(game, lookTool)
			
			
			
func addMessage(text:String, color:Color) -> void:
	
	combatLog.addMessage(text, color)



func saveInitialMessage(text:String, color:Color) -> void:

	initialMessage = LogMessage.instantiate()
	initialMessage.text = text
	initialMessage.color = color


func addLogRow(text:String, color:Color) -> void:
	
	
	var item1:Node = initialMessage.duplicate()
	
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
