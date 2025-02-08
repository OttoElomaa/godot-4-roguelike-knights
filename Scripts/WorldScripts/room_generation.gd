extends Node2D



var world:Node = null

var roomCount := 6



func generateWalkerPath() -> Array:
	
	var walkerRoomPositions:Array = $Walker.walk(400, Vector2.ZERO, true)
	#for coord in walkerSteps:
		#$GlobalFloorTiles.set_cell(coord, 6, Vector2i.ZERO)
	return walkerRoomPositions
	
	
