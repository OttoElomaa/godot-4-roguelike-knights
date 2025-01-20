extends Node2D


var gridPosition := Vector2i.ZERO

func move(vector):
	
	var tiles = get_tree().get_first_node_in_group("tilecontroller")
	
	gridPosition += vector
	tiles.placeGridObjectOnMap(self, gridPosition)
