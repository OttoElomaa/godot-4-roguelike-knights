extends PanelContainer


var game:Node = null
var dungeonSelector:Node = null

@export var dungeonName := "Character Name"
@export var difficulty := 1
@export var biome := 1
@export var floorsCount := 1

@export var isDebugMap := false



class DungeonInfo:
	var dungeonName := ""
	var difficulty := 0
	var biome := 0
	var floorsCount := 0
	
	func _init(dName, difficulty, biome, floors) -> void:
		self.dungeonName = dName
		self.difficulty = difficulty
		self.biome = biome
		self.floorsCount = floors



func setup(game:Node, selector:Node):
	#### BASIC SETUP
	self.game = game
	self.dungeonSelector = selector
	
	#### SET NAME
	dungeonName = NameGenerator.generate_dungeon_name()
	if isDebugMap:
		dungeonName = "Debug Dungeon"
	
	#### SET BIOME AND FLOORS COUNT
	biome = randi_range(0,2)
	floorsCount = randi_range(1,3)
	
	#### SET VISUALS LIKE LABEL TEXTS
	$Margin/VBox/NameLabel.text = dungeonName
	$Margin/VBox/FloorsLabel.text = "%d Floors" % floorsCount
	
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
	
	var infoObject = DungeonInfo.new(dungeonName, difficulty, biome, floorsCount)
	
	game.startGameFromDungeonIcon(infoObject, isDebugMap)
	dungeonSelector.queue_free()
