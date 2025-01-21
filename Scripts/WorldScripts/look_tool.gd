extends Node2D


var gridPosition := Vector2i.ZERO

func move(vector):
	
	var tiles = get_tree().get_first_node_in_group("tilecontroller")
	
	gridPosition += vector
	tiles.placeGridObjectOnMap(self, gridPosition)


func processLook(world):
	
	var showInfo := false
	
	if Input.is_action_just_pressed("ui_up"):
		move(Vector2i.UP)
		showInfo = true
	elif Input.is_action_just_pressed("ui_down"):
		move(Vector2i.DOWN)
		showInfo = true
	elif Input.is_action_just_pressed("ui_left"):
		move(Vector2i.LEFT)
		showInfo = true	
	elif Input.is_action_just_pressed("ui_right"):
		move(Vector2i.RIGHT)
		showInfo = true
	
	#### OPTION 1: NOTHING TO SHOW
	if not showInfo:
		return
	
	else:
		world.getUi().showLookInfo(world, self)
		


func showLookInfo():
	pass	
		
