extends PanelContainer




@export var characterScene:PackedScene = null
@export var characterName := "Character Name"
@export var characterSprite:Texture = null

var world:Node = null



func setup(world):
	self.world = world
	$VBox/NameLabel.text = characterName
	$VBox/CharacterIcon.texture = characterSprite


func _on_button_pressed() -> void:
	print("Character select button pressed")
	prints("button char scene: ", self.characterScene)
	world.startGameFromPlayerScene(self.characterScene)
