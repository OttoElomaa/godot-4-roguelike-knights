extends PanelContainer


var game:Node = null
var dungeonSelector:Node = null

@export var dungeonName := "Character Name"
@export var difficulty := 1
@export var biome := 1


class DungeonInfo:
	var dungeonName := ""
	var difficulty := 0
	var biome := 0
	
	func _init(dName, difficulty, biome) -> void:
		self.dungeonName = dName
		self.difficulty = difficulty
		self.biome = biome



func setup(game:Node, selector:Node):
	self.game = game
	self.dungeonSelector = selector
	
	$Margin/VBox/NameLabel.text = dungeonName
	#$Margin/VBox/DungeonIcon.texture = characterSprite


func _on_button_pressed() -> void:
	print("Dungeon select button pressed")
	
	var infoObject = DungeonInfo.new(dungeonName, difficulty, biome)
	
	game.startGameFromDungeonIcon(infoObject)
	dungeonSelector.queue_free()
