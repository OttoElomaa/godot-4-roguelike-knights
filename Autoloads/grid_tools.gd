extends Node2D


var tileSize := 32



func localToGrid(localPos: Vector2i) -> Vector2i:
	
	var gridPos = $JustForFunctions.local_to_map(localPos)
	return gridPos



func gridToWorld(grid_pos: Vector2i) -> Vector2i:
	
	var halfVector := Vector2i(tileSize/2, tileSize/2)
	var world_pos: Vector2i = grid_pos * tileSize + halfVector
	return world_pos



func worldToGrid(world_pos: Vector2i) -> Vector2i:
	var grid_pos: Vector2i = world_pos / tileSize
	return grid_pos
