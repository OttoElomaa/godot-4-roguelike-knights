extends PanelContainer


@onready var mainVbox := $Margin/MainVBox
@onready var labelsHbox := $Margin/MainVBox/HBox/StatsHbox
@onready var labelsHboxTwo := $Margin/MainVBox/HBox/StatsHboxTwo


@onready var stateLabel:Label = mainVbox.get_node("StateLabel")
@onready var lookLabel:Label = mainVbox.get_node("LookLabel")
@onready var nameLabel:Label = mainVbox.get_node("NameText")

@onready var healthLabel:Label = labelsHbox.get_node("HealthLabel")
@onready var armorLabel:Label = labelsHbox.get_node("ArmorLabel")
@onready var blockLabel:Label = labelsHbox.get_node("BlockLabel")
@onready var evasionLabel:Label = labelsHbox.get_node("EvasionLabel")

@onready var guardLabel:Label = labelsHboxTwo.get_node("GuardLabel")
@onready var zealLabel:Label = labelsHboxTwo.get_node("ZealLabel")

var player:Node = null


func setupPlayerView(player:Player):
	
	self.player = player
	
	stateLabel.hide()
	lookLabel.hide()
	nameLabel.text = "Character name: %s" % player.creatureName



func updatePlayerStats():
	updateView(player)
	
func showMouseLookCreature(creature:Node):
	toggleStatBlock(true)
	updateView(creature)



func updateView(creature:Node):
	var labelsBox := $Margin/LookHbox
	
	if player == null:
		lookLabel.text = "%d, %d" % [creature.gridPosition.x, creature.gridPosition.y]
		nameLabel.text = "It's a creature called %s" % creature.creatureName
	
	healthLabel.text = "Health: %d" % creature.stats.health.current
	armorLabel.text = "Armor: %d" % creature.stats.armor.current
	blockLabel.text = "Block: %d" % creature.stats.block.current
	evasionLabel.text = "Evasion: %d" % creature.stats.evasion.current
	
	guardLabel.text = "Guard: %d" % creature.stats.guard.current
	zealLabel.text = "Zeal: %d" % creature.stats.zeal.current



func toggleStatBlock(toShow:bool):
	if toShow:
		$Margin/MainVBox/HBox.show()
	else:	
		$Margin/MainVBox/HBox.hide()



func showLookInfo(game:Node, lookTool:Node):
	
	var grid = game.getGrid()
	lookLabel.text = "%d, %d" % [lookTool.gridPosition.x, lookTool.gridPosition.y] 
	
	var pos = lookTool.gridPosition
	
	#### OPTION 2.1: A WALL TILE
	#if not grid.is_tile_empty(lookTool.gridPosition):
	if grid.getTileValue(pos) == 2:
		nameLabel.text = "It's a wall."
		toggleStatBlock(false)
		return
	elif grid.getTileValue(pos) == 1:
		nameLabel.text = "It's an impassable void."
		toggleStatBlock(false)
		return
	
	else:
		var creatures : Array = game.getCreatures()
		#### OPTION 2.2.1: A CREATURE
		for creature in creatures:
			if pos == creature.gridPosition:
				toggleStatBlock(true)
				updateView(creature)
				return
		#### OPTION 2.2.2: EMPTY TILE
		if grid.getTileValue(pos) == -1:
			toggleStatBlock(false)
			nameLabel.text = "It's an open space."
			return
			
		nameLabel.text = "This tile is bugged?"
		
		
		
func updateStateLabel(isLook):
	if isLook:
		stateLabel.text = "Input State = Look"
	else:
		stateLabel.text = "Input State = Explore"
