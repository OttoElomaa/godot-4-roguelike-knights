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
	

func getEntityGridDistance(object1:Node, object2:Node) -> int:
	return getGridDistanceOfCoords(object1.gridPosition, object2.gridPosition)
	

	
func getGridDistanceOfCoords(coord1:Vector2i, coord2:Vector2i):
	var distanceX = abs(coord1.x - coord2.x)
	var distanceY = abs(coord1.y - coord2.y)
	return max(distanceX, distanceY)



#### PICK CLOSEST TARGET FROM ARRAY
func findClosestCreature(firstC:Node, creatureArray:Array) -> Node:
	if creatureArray.is_empty(): ## EMPTY ARRAY
		return null
		
	#### LOOP THROUGH ARRAY, SET CLOSEST
	var closest:Node = creatureArray[0]
	for creature in creatureArray:
		
		var distCre = getEntityGridDistance(firstC, creature)
		var distClose = getEntityGridDistance(firstC, closest)
		if distCre <= distClose:
			closest = creature
			
	return closest
