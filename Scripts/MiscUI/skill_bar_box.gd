extends PanelContainer


var skill:Node = null

func setup(skill:Node):
	
	self.skill = skill
	
	var texture:Texture = skill.skillIcon
	
	$TextureRect.texture = texture
	$NameLabel.text = skill.skillName



func updateVisuals():
	
	if skill.isOnCooldown():
		$Overlay.show()
		$NameLabel.text = "%s (%d)" % [skill.skillName, skill.getCooldown()]
	else:
		$Overlay.hide()
		$NameLabel.text = skill.skillName
