extends PanelContainer


@onready var mainVbox := $Margin/MainVBox
@onready var labelsHbox := $Margin/MainVBox/HBox/StatsHbox
@onready var labelsHboxTwo := $Margin/MainVBox/HBox/StatsHboxTwo


@onready var stateLabel:Label = mainVbox.get_node("HBoxUpper/StateLabel")
@onready var lookLabel:Label = mainVbox.get_node("HBoxUpper/LookLabel")
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
	
	$Margin/MainVBox/HBoxUpper.hide()
	nameLabel.text = "Character name: %s" % player.creatureName



func updatePlayerStats():
	updateView(player)
	
	
	
func showMouseLookCreature(creature:Node):
	
	stateLabel.text = "Looking at..."
	toggleStatBlock(true)
	updateView(creature)



func showTargetCreature(creature:Node):
	
	stateLabel.text = "Targeting..."
	toggleStatBlock(true)
	updateView(creature)


func updateView(creature:Node):
	
	var s = creature.stats
	
	if player == null:
		lookLabel.text = "%d, %d" % [creature.gridPosition.x, creature.gridPosition.y]
		nameLabel.text = "a creature called %s" % creature.creatureName
	
	
	healthLabel.text = "Health: %d" % s.health.current
	
	armorLabel.text = "Armor: %d" %s.armor.current
	blockLabel.text = "Block: %d" % s.block.current
	evasionLabel.text = "Evasion: %d" % s.evasion.current
	
	guardLabel.text = "Guard: %d" % s.guard.current
	zealLabel.text = "Zeal: %d" % s.zeal.current
	
	colorLabelIfChange(armorLabel, s.armor)
	colorLabelIfChange(blockLabel, s.block)
	colorLabelIfChange(evasionLabel, s.evasion)
	
	
	
func colorLabelIfChange(label:Label, stat:Object):
	
	var color := Color.WHITE
	if stat.current > stat.altered:
		color = MyColors.fontAllyHeal
	elif stat.current < stat.altered:
		color = MyColors.fontAllyHurt
		
	label.set("theme_override_colors/font_color", color)
	


func toggleStatBlock(toShow:bool):
	if toShow:
		$Margin/MainVBox/HBox.show()
	else:	
		$Margin/MainVBox/HBox.hide()



func showLookInfo(game:Node, lookTool:Node):
	
	var grid = game.getGrid()
	
	stateLabel.text = "Looking at..."
	lookLabel.text = "%d, %d" % [lookTool.gridPosition.x, lookTool.gridPosition.y] 
	
	var pos = lookTool.gridPosition
	
	#### OPTION 2.1: A WALL TILE
	#if not grid.is_tile_empty(lookTool.gridPosition):
	if grid.getTileValue(pos) == 2:
		nameLabel.text = "a wall."
		toggleStatBlock(false)
		return
	elif grid.getTileValue(pos) == 1:
		nameLabel.text = "an impassable void."
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
			nameLabel.text = "an open space."
			return
			
		nameLabel.text = "This tile is bugged?"
		
