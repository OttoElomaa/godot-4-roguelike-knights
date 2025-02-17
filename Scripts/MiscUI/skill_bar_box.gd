extends PanelContainer


var skill:Node = null
@onready var textureR := $VBox/PanelC/SkillIcon
@onready var label := $VBox/NameLabel
@onready var overlay := $VBox/PanelC/Overlay
@onready var cooldownL := $VBox/PanelC/CooldownLabel

@onready var indexL := $VBox/IndexLabel


func setup(skill:Node, index:int):
	
	self.skill = skill
	
	var texture:Texture = skill.skillIcon
	
	textureR.texture = texture
	label.text = skill.skillName
	
	indexL.text = "%d" % (index + 1)


func updateVisuals():
	
	if skill.isOnCooldown():
		overlay.show()
		cooldownL.text = "(%d)" % [skill.getCooldown()]
	else:
		overlay.hide()
		cooldownL.text = ""
