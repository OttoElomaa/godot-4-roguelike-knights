extends Node


const DIRECTIONS = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]

var walkerPos = Vector2.ZERO
var direction = Vector2.RIGHT
#var borders = Rect2()
var step_history = []
var steps_since_turn = 0

var path_tiles := []
var roomPositions := []

#var rooms = []
# NEW STUFF
#var room_edge_tiles = []
#var room_edge_tiles_2 = []
#var tiles_to_purge = []
#var enemy_placement_rooms = []


func walk(steps, start, is_messy):
	
	var variation_array = [7,9]
	var normal_variation = variation_array[randi_range(0,1)]
	
	#### VERY FIRST room of dungeon
	#place_room(start,false)
	
	#### REMOVE IF BROKEY. Initial corridor of sorts
	#direction = Vector2.RIGHT
	#for i in range(10):
		#if step():
			#step_history.append(position)
			#path_tiles.append(position)
		#else:
			#change_direction()
	
	
	#### CHANGE BACK to 6 if brokey
	for step in range(steps):
		
		#### NEW: Variation. Messiness is applied to gold-standard dungeon - RESTORE 8 if bad 
		var steps_until_turn = normal_variation
		if is_messy:
			steps_until_turn = randi_range(8,16)
		
		
		#### CHANGE BACK from RANDI to FIXED if broken
		if steps_since_turn >= steps_until_turn:
			change_direction()
			roomPositions.append(walkerPos)
		
		if step():
			step_history.append(walkerPos)
			path_tiles.append(walkerPos)
		else:
			change_direction()
	
	#### ONE LAST room		
	#enemy_placement_rooms.append( place_room(position,true) )			
			
	return roomPositions




func step():
	var target_position:Vector2 = walkerPos + direction
	var distX = abs(target_position.x)
	var distY = abs(target_position.y)
	
	if distX <= 100 and distY <= 100:
		steps_since_turn += 1
		walkerPos = target_position
		return true
	else:
		return false

func change_direction():
		
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.shuffle()
	
	for dir in directions:
	
		var targetPosition = walkerPos + dir
		var distX = abs(targetPosition.x)
		var distY = abs(targetPosition.y)
		
		if distX <= 100 and distY <= 100:
			direction = dir
			return
		else:
			direction = Vector2.RIGHT
		return
				
				
				
				
				
