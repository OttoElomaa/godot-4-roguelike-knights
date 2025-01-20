extends PanelContainer




func setup(skill:Node):
	
	var texture:Texture = skill.skillIcon
	
	$TextureRect.texture = texture
	$NameLabel.text = skill.skillName
