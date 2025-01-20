extends VBoxContainer


var LogMessage = load("res://Scenes/BasicLogMessage.tscn")


func addMessage(text:String) -> void:
	
	var message = LogMessage.instantiate()
	message.text = text
	add_child(message)
	
	
