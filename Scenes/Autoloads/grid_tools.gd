extends Node2D


var tileSize := 32


func grid_to_world(grid_pos: Vector2i) -> Vector2i:
	
	var halfVector := Vector2i(tileSize/2, tileSize/2)
	var world_pos: Vector2i = grid_pos * tileSize + halfVector
	return world_pos



func world_to_grid(world_pos: Vector2i) -> Vector2i:
	var grid_pos: Vector2i = world_pos / tileSize
	return grid_pos
