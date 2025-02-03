extends Node



var world:Node = null

var roomCount := 6



func generateRoomsVersionTwo(world):
	
	var rng := RandomNumberGenerator.new()
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		
	var roomPositions = [Vector2i.ZERO]
	
	#### ROOMCOUNT = HOW MANY TIMES WE MAKE ROOM
	for i in range(1, roomCount + 1):
		var previousCoords = roomPositions[i - 1]
		var success := false
		
		#### TRY TO DESIGNATE ROOM POSITION IN RANDOM DIRECTION
		while not success:
			var direction = directions[rng.randi_range(0,3)]
			var newPos = movePosition(previousCoords, direction)
			if not newPos in roomPositions:
				success = true
				roomPositions.append(newPos)
	
	var rooms := {}
	var scene:Node = null
	
	#### LOAD A ROOM SCENE, STORE ITS POSITION IN DICT
	var siz = roomPositions.size()
	for i in range(siz):
		var coord = roomPositions[i]
		scene = FileLoader.createRandomRoom()
		rooms[coord] = scene
		
		#### STORE THE LAST ROOM'S CENTER GRID POSITION, TO PLACE EXIT TILE
		if i == siz - 1:
			world.exitGridPos = scene.getStartPosition() + coord * 16
			world.lastRoom = scene
			prints("EXIT ROOM NUM: ", i)
		elif i == 0:
			world.startingGridPos = scene.getStartPosition() + coord * 16
			world.firstRoom = scene
			prints("ENTRANCE ROOM NUM: ", i)
	
	#### RETURN DICTIONARY TO ROOM SCRIPT
	return rooms
		


func movePosition(position, direction):
	return Vector2i(position.x + direction.x, position.y + direction.y)



func opposite_direction(direction):
	var opposite = {
		'up': 'down',
		'down': 'up',
		'left': 'right',
		'right': 'left'
		}
	return opposite[direction]



func move_position(position:Vector2i, direction) -> Vector2i:
	
	var x = position.x
	var y = position.y
	
	if direction == 'up':
		return Vector2i(x, y - 1)
	elif direction == 'down':
		return Vector2i(x, y + 1)
	elif direction == 'left':
		return Vector2i(x - 1, y)
	elif direction == 'right':
		return Vector2i(x + 1, y)
		
	return position
