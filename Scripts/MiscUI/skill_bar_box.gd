extends PanelContainer


var skill:Node = null
@onready var textureR := $VBoxContainer/PanelC/TextureRect
@onready var label := $VBoxContainer/NameLabel
@onready var overlay := $VBoxContainer/PanelC/Overlay


func setup(skill:Node):
	
	self.skill = skill
	
	var texture:Texture = skill.skillIcon
	
	textureR.texture = texture
	label.text = skill.skillName



func updateVisuals():
	
	if skill.isOnCooldown():
		overlay.show()
		label.text = "%s (%d)" % [skill.skillName, skill.getCooldown()]
	else:
		overlay.hide()
		label.text = skill.skillName
