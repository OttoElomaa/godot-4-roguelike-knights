extends CanvasLayer


@onready var dungeonNameLabel := $LookMargin/VBox/FloorInfo/Margin/Hbox/DungeonName
@onready var floorsLabel := $LookMargin/VBox/FloorInfo/Margin/Hbox/FloorLabel

@onready var goldLabel := $LookMargin/VBox/FloorInfo/Margin/Hbox/GoldLabel
@onready var enemiesLabel := $LookMargin/VBox/FloorInfo/Margin/Hbox/EnemiesLabel

@onready var lookPanel := $LookMargin/VBox/LookPanel
@onready var playerPanel := $LookMargin/VBox/PlayerPanel

@onready var skillBar := $BottomPanel/Hbox/SkillsMargin/SkillBar
@onready var combatLog := $BottomPanel/Hbox/LogMargin/LogPanel/MarginContainer/CombatLog

var LogDoubleRow:PackedScene = load("res://Dungeon-UI/logDoubleRow.tscn")
var LogMessage = load("res://Dungeon-UI/BasicLogMessage.tscn")

var initialMessage:Node = null
var caveats := []


func setup(world):
	
	dungeonNameLabel.text = world.dungeonName
	floorsLabel.text = "Floor %d of %d" % [ProgressData.dungeonFloorLevel, ProgressData.maxDungeonFloor]
	
	playerPanel.setupPlayerView(world.player)



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("H"):
		toggleHelp(true)



func updateVisualsOnTurn():
	updatePlayerPanel()
	updateProgressLabels()
	
	for box in skillBar.get_children():
		if box.skill != null:
			box.updateVisuals()	



func toggleHelp(cycle:bool):
	if not cycle:
		$HelpScreen.hide()
		return
		
	var h := $HelpScreen
	if not h.visible:
		$HelpScreen.show()
	else:
		$HelpScreen.hide()



func displayPlayerSkills(player):
	
	var boxes:Array = skillBar.get_children()
	var skills:Array = player.getSkills()
	
	if skills.is_empty():
		return
	#### SET EACH SKILL'S ICON IN SKILL BAR	
	for i in range(skills.size()):
		boxes[i].setup(skills[i], i)
	





func updateProgressLabels():
	goldLabel.text = "Gold: %d" % ProgressData.gold
	enemiesLabel.text = "Enemies killed: %d" % ProgressData.enemiesKilled

#########################################################################################
#### LOOK STUFF

func updatePlayerPanel():
	playerPanel.updatePlayerStats()



func showTargetCreature(creature:Node):
	
	if creature == null:
		lookPanel.showNotarget()
		return
		
	if not is_instance_valid(creature):
		return
	if creature.is_queued_for_deletion():
		return
	lookPanel.showTargetCreature(creature)


func showMouseLookCreature(creature:Node):
	lookPanel.showMouseLookCreature(creature)


func showLookInfo(game:Node, lookTool:Node):
	
	lookPanel.showLookInfo(game, lookTool)
			

func showInteractObjectInfo():
	
	var itemInfo = $LookMargin/VBox/ItemInfo/Margin/Hbox
	var itemNameLabel = itemInfo.get_node("ItemName")
	if States.currentInteractObject:
		itemNameLabel.text = States.currentInteractObject.objectName
		
	else:
		itemNameLabel.text = "No items nearby."

##############################################################################
#### MESSAGE STUFF
#### ROW = INITIAL MESSAGE + 2nd LOG MESSAGE
#### ( SaveInitialMessage + AddLogRow()   )
			
			
func addMessage(text:String, color:Color) -> void:
	
	combatLog.addMessage(text, color)



func saveInitialMessage(text:String, color:Color) -> void:
	initialMessage = LogMessage.instantiate()
	initialMessage.text = text
	initialMessage.color = color


func addLogRow(text:String, color:Color) -> void:
	var item1:Node = initialMessage.duplicate()
	
	var item2:Node = LogMessage.instantiate()
	
	var textWithCaveats := text
	for c in caveats:
		textWithCaveats += " %s" % c
	caveats = []
		
	item2.text = textWithCaveats
	item2.color = color
	
	var row = LogDoubleRow.instantiate()
	row.setupRowFromArray(self, item1, item2)
	


func addLogItemHelp(item:Node):
	combatLog.addItem(item)


#### THIS COMMAND ADDS THE INITIAL MESSAGE AS A ROW WITHOUT CLEARING IT
func addInitialRow():
	if initialMessage == null:
		return
	addLogItemHelp(initialMessage)


func deleteInitialRow():
	initialMessage = null


func addCaveat(text:String):
	caveats.append(text)


func clearCaveats():
	caveats = []
	

####################################################################################


func toggleLoadingScreen(visible:bool):
	if visible:
		$LoadingImage.show()
	else:
		$LoadingImage.hide()
