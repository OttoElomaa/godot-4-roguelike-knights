extends Node


var turnPoints := []
var walkerPos = Vector2i.ZERO
var stepsTaken := 0
var direction = Vector2i.RIGHT





const DIRECTIONS = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]



#var borders = Rect2()
var step_history = []
var steps_since_turn = 0

var path_tiles := []
var roomPositions := []



func walk(walkAmount, grid):
	
	
	while stepsTaken < walkAmount:
		
		var tooClose := true
		change_direction()
		walkerPos.x += randi_range(-5,5)
		walkerPos.y += randi_range(-5,5)
		turnPoints.append(walkerPos)
		
		while tooClose:
			tooClose = false
			walkerPos += direction
			for pos in turnPoints:
				if grid.getGridDistanceOfCoords(walkerPos, pos) < 16:
					tooClose = true
		
		stepsTaken += 1
				
	return turnPoints		
	
	


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
				
