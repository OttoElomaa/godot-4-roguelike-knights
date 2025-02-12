extends PanelContainer


@onready var labelsHbox := $Margin/LookHbox


@onready var stateLabel:Label = labelsHbox.get_node("StateLabel")
@onready var lookLabel:Label = labelsHbox.get_node("LookLabel")
@onready var nameLabel:Label = labelsHbox.get_node("NameText")

@onready var healthLabel:Label = labelsHbox.get_node("HealthLabel")
@onready var armorLabel:Label = labelsHbox.get_node("ArmorLabel")
@onready var blockLabel:Label = labelsHbox.get_node("BlockLabel")
@onready var evasionLabel:Label = labelsHbox.get_node("EvasionLabel")


func showMouseLookCreature(creature:Node):
	var labelsBox := $Margin/LookHbox
	
	labelsBox.get_node("LookLabel").text = "%d, %d" % [creature.gridPosition.x, creature.gridPosition.y]
	labelsBox.get_node("NameText").text = "It's a creature called %s" % creature.creatureName
	
	labelsBox.get_node("HealthLabel").text = "Health: %d" % creature.stats.health.current
	labelsBox.get_node("ArmorLabel").text = "Armor: %d" % creature.stats.armor.current
	labelsBox.get_node("BlockLabel").text = "Block: %d" % creature.stats.block.current
	labelsBox.get_node("EvasionLabel").text = "Evasion: %d" % creature.stats.evasion.current
	
	labelsBox.get_node("ZealLabel").text = "Zeal: %d" % creature.stats.zeal.current
	labelsBox.get_node("GuardLabel").text = "Guard: %d" % creature.stats.guard.current


func showLookInfo(game:Node, lookTool:Node):
	
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
		
		
		
func updateStateLabel(isLook):
	if isLook:
		stateLabel.text = "Input State = Look"
	else:
		stateLabel.text = "Input State = Explore"
