extends PanelContainer


var game:Node = null
var dungeonSelector:Node = null

@export var dungeonName := "Character Name"
@export var difficulty := 1
@export var biome := 1

@export var isDebugMap := false



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
	
	dungeonName = NameGenerator.generate_dungeon_name()
	if isDebugMap:
		dungeonName = "Debug Dungeon"
	
	biome = randi_range(0,2)
	
	$Margin/VBox/NameLabel.text = dungeonName
	
	var difficultyText := ""
	match difficulty:
		1:
			difficultyText = "This is an early-level dungeon."
		2:
			difficultyText = "This is a medium difficult dungeon."
	
	var biomeText := ""
	match biome:
		0:
			biomeText = "A ruined castle."
		1:
			biomeText = "An ancient grove."
		2:
			biomeText = "A desert ruin."
	
	$Margin/VBox/DifficultyLabel.text = difficultyText
	$Margin/VBox/BiomeLabel.text = biomeText
	#$Margin/VBox/DungeonIcon.texture = characterSprite


func _on_button_pressed() -> void:
	print("Dungeon select button pressed")
	
	var infoObject = DungeonInfo.new(dungeonName, difficulty, biome)
	
	game.startGameFromDungeonIcon(infoObject, isDebugMap)
	dungeonSelector.queue_free()
