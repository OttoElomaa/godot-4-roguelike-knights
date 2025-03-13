extends PanelContainer


var game:Node = null
var dungeonSelector:Node = null

@export var dungeonName := "Character Name"
@export var difficulty := 1
@export var biome := 1

#@export var dungeonScene:PackedScene = null
#@export var characterSprite:Texture = null





func setup(game:Node, selector:Node):
	self.game = game
	self.dungeonSelector = selector
	
	$Margin/VBox/NameLabel.text = dungeonName
	#$Margin/VBox/DungeonIcon.texture = characterSprite


func _on_button_pressed() -> void:
	print("Dungeon select button pressed")
	
	game.startGameFromDungeonIcon()
	dungeonSelector.queue_free()
