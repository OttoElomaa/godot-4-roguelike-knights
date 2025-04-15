extends PanelContainer



var itemName:String:
	get:
		return $Margin/HBox/Name.text
		
var itemIcon:Texture:
	get:
		return $Margin/HBox/Icon.texture


func setup(item:Node):
	
	toggleFocus(false)
	
	#### NO ITEM? DISPLAY EMPTY SLOT INFO
	if not item:
		displayEmptySlot()
		return
	
	$Margin/HBox/Icon.texture = item.itemIcon
	$Margin/HBox/Name.text = item.itemName
	
	

func setEquipmentFontColor(item):
	
	pass	
	

func toggleFocus(toHighlight:bool):
	
	if toHighlight:
		$HighlightPanel.show()
	else:
		$HighlightPanel.hide()
	
	

func displayEmptySlot():
	$Margin/HBox/Icon.texture = null
	$Margin/HBox/Name.text = "No items"	
	
