extends Node



var world:Node = null

var roomCount := 6



func generateRoomsVersionTwo(world):
	
	var rng := RandomNumberGenerator.new()
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		
	var roomPositions = [Vector2i.ZERO]
	
	for i in range(1, roomCount + 1):
		var previousCoords = roomPositions[i - 1]
		var success := false
		
		while not success:
			var direction = directions[rng.randi_range(0,3)]
			var newPos = movePosition(previousCoords, direction)
			if not newPos in roomPositions:
				success = true
				roomPositions.append(newPos)
	
	var rooms := {}
	var scene:PackedScene = null
	
	for coords in roomPositions:
		
		match rng.randi_range(0,2):
			0:
				scene = load("res://Rooms/Detached/NormalRoom02.tscn")
			1:
				scene = load("res://Rooms/Detached/Cavern/Cavern01.tscn")
			2:
				scene = load("res://Rooms/Detached/Cells/Cells01.tscn")
		
		rooms[coords] = scene
	
	return rooms
		

func movePosition(position, direction):
	return Vector2i(position.x + direction.x, position.y + direction.y)


func generateRooms(world):

	var roomDicts:Array = createRoomsList()
	var roomScenes := {}
	
	for roomDictionary in roomDicts:
		var roomScene = loadRoom(roomDictionary)
		roomScenes[roomScene] = roomDictionary["position"]
		#roomScenes.append(roomScene)
	
	return roomScenes


func createRoomsList():
	
	self.world = world
	
	var rng := RandomNumberGenerator.new()
	var directions := ["up", "down", "left", "right"]
	var firstPos := Vector2i.ZERO
	
	var rooms := []

	# The first room has no entrance, only an exit
	var first_exit = directions[rng.randi_range(0,3)]
	
	rooms.append({
		"entrance": "",
		"exit": first_exit,
		"position": firstPos,
		})
	
		
	######################################	
	# Determine subsequent rooms
	var previousExit := ""
	var entrance := ""
	for i in range(1, 4):
		
		var previousRoom = rooms[i-1]
		previousExit = previousRoom['exit']
		entrance = opposite_direction(previousExit)

		# Calculate the new position based on the previous exit direction
		var previousPos = previousRoom["position"]
		var new_position = move_position(previousPos, previousExit)
		

		
		var exit := ""
		#### ROOM 3 IS LAST AND HAS NO EXIT
		#### CHECK THAT ENTRANCE AND EXIT ARE DIFFERENT
		if i < 3:
			exit = directions[rng.randi_range(0,3)]
			while exit == entrance:
				exit = directions[rng.randi_range(0,3)]
		
		rooms.append({
			'entrance': entrance,
			'exit': exit,
			'position': new_position
			})
	
	prints("rooms count: ", rooms.size())
	for room in rooms:
		prints("room. entrance: ", room["entrance"])
		prints("exit: ", room["exit"])	
		prints("position: ", room["position"])
		print("")		
	return rooms


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



func loadRoom(room:Dictionary):
	
	var entrance:String = room["entrance"]
	var exit:String = room["exit"]
	var result := ""
	var combination = entrance + "-" + exit
	
	prints("room combp text: ", combination)
	
	#################################
	match combination:
		"-right", "right-":
			return load("res://Rooms/Basic/BasicEntranceRight01.tscn")
		"-left", "left-":
			return load("res://Rooms/Basic/BasicEntranceLeft01.tscn")
		"-up", "up-":
			return load("res://Rooms/Basic/BasicEntanceUp01.tscn")
		"-down", "down-":
			return load("res://Rooms/Basic/BasicEntranceDown01.tscn")
			
		##########################
		"up-down", "down-up":
			return load("res://Rooms/Basic/BasicUpDown01.tscn")
		"left-right", "right-left":
			return load("res://Rooms/Basic/BasicLeftRight01.tscn")
		
		#####################################	
		"up-right", "right-up":
			return load("res://Rooms/Basic/BasicUpRight01.tscn")
			
		"up-left", "left-up":
			return load("res://Rooms/Basic/BasicUpLeft01.tscn")
			
		"down-left", "left-down":
			return load("res://Rooms/Basic/BasicDownLeft01.tscn")
			
		"down-right", "right-down":
			return load("res://Rooms/Basic/BasicDownRight01.tscn")
	
	#match entrance:
		#"up":
			#match exit:
				#"down":
					#result = "up-down"
				#"left":
					#result = "up-left"
				#"right":
					#result = "up-right"		
		#"down":
			#match exit:
				#"up":
					#result = "up-down"
				#"left":
					#result = "down-left"
				#"right":
					#result = "down-right"
		#"left":
			#match exit:
				#"down":
					#result = "down-left"
				#"up":
					#result = "up-left"
				#"right":
					#result = "left-right"
		#"right":
			#match exit:
				#"down":
					#result = "down-right"
				#"up":
					#result = "up-right"
				#"left":
					#result = "left-right"
