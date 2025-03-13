extends PanelContainer




@export var characterScene:PackedScene = null
@export var characterName := "Character Name"
@export var characterSprite:Texture = null

var game:Node = null



func setup(world):
	self.game = world
	$Margin/VBox/NameLabel.text = characterName
	$Margin/VBox/CharacterIcon.texture = characterSprite


func _on_button_pressed() -> void:
	print("Character select button pressed")
	prints("button char scene: ", self.characterScene)
	game.startGameFromPlayerScene(self.characterScene)
