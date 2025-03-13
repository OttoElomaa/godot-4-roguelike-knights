extends Node2D




func setup(game:Node):
	for charButton in $UI/PanelContainer/MarginContainer/Vbox/Chars_Hbox.get_children():
		charButton.setup(game)
