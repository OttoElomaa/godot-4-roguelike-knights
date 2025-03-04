extends HBoxContainer



func setupRowFromArray(ui:Node, item1:Node, item2:Node):
	
	#for item in items:
	add_child(item1)
	add_child(item2)
	ui.addLogItemHelp(self)
