extends PanelContainer



var itemName:String:
	get:
		return $Margin/HBox/Name.text
		
var itemIcon:Texture:
	get:
		return $Margin/HBox/Icon.texture


func setup(item:Node):
	
	$Margin/HBox/Icon.texture = item.itemIcon
	$Margin/HBox/Name.text = item.itemName
	
	toggleFocus(false)
	
	

func toggleFocus(toHighlight:bool):
	
	if toHighlight:
		$HighlightPanel.show()
	else:
		$HighlightPanel.hide()
	
	
	
	
