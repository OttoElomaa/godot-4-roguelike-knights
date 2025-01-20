extends PanelContainer



var text: String:
	set(val):
		$Text.text = val
	get:
		return $Text.text


#func setText(text:String):
	#$Text.text = text
