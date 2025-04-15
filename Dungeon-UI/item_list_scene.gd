extends PanelContainer


var itemScene: Node = null

var SettingsWhite:LabelSettings = load("res://Resources/Fonts/LabelSettingSmallFontWhite.tres")
var SettingsGrey:LabelSettings = load("res://Resources/Fonts/LabelSettingSmallFontFaintGrey.tres")


var itemName:String:
	get:
		return $Margin/HBox/Name.text
		
var itemIcon:Texture:
	get:
		return $Margin/HBox/Icon.texture


func setup(item:Node):
	
	toggleFocus(false)
	self.itemScene = item
	
	#### NO ITEM? DISPLAY EMPTY SLOT INFO
	if not item:
		displayEmptySlot()
		$Margin/HBox/Name.label_settings = SettingsGrey
		return
	
	$Margin/HBox/Icon.texture = item.itemIcon
	$Margin/HBox/Name.text = item.itemName
	$Margin/HBox/Name.label_settings = SettingsWhite
	
	

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
	
