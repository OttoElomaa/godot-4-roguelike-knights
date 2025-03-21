extends PanelContainer


var skill:Node = null
@onready var textureR := $VBox/PanelC/SkillIcon
@onready var label := $VBox/NameLabel
@onready var cooldownOverlay := $VBox/PanelC/CooldownOverlay
@onready var costOverlay := $VBox/PanelC/CostOverlay
@onready var cooldownL := $VBox/PanelC/CooldownLabel

@onready var indexL := $VBox/IndexLabel


func setup(skill:Node, index:int):
	
	self.skill = skill
	
	var texture:Texture = skill.skillIcon
	
	textureR.texture = texture
	label.text = skill.skillName
	
	indexL.text = "%d" % (index + 1)


func updateVisuals():
	
	cooldownOverlay.hide()
	costOverlay.hide()
	var costText = skill.getCostString()
	
	#### SHOW IF SKILL IS ON COOLDOWN
	if skill.isOnCooldown():
		cooldownOverlay.show()
		cooldownL.text = "(%d)" % [skill.getCooldown()]
		
	#### SHOW IF PLAYER CAN'T AFFORD SKILL USE
	elif costText != "":
		costOverlay.show()
		cooldownL.text = costText
		
	#### SKILL IS NORMAL AND USABLE
	else:
		cooldownL.text = ""
