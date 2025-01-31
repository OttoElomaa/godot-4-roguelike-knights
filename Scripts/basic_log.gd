extends PanelContainer


var LogMessage = load("res://Scenes/UI/BasicLogMessage.tscn")


func addMessage(text:String, color:Color) -> void:
	
	var message = LogMessage.instantiate()
	message.text = text
	message.color = color
	$Scrolling/Rows.add_child(message)
	
	await get_tree().process_frame
	$Scrolling.scroll_vertical = $Scrolling.get_v_scroll_bar().max_value
	
	
func addItem(item:Node):
	
	$Scrolling/Rows.add_child(item)
	await get_tree().process_frame
	$Scrolling.scroll_vertical = $Scrolling.get_v_scroll_bar().max_value
