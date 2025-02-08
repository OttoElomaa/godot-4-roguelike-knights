extends Node


const DIRECTIONS = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]

var walkerPos = Vector2i.ZERO
var direction = Vector2i.RIGHT

var stepsTaken := 0
var turnPoints := []
#### TRACK HOW MANY UNSUCCESSFUL STEPS AFTER LAST TURN
var faultyStepsCount := 0


func walk(walkAmount, grid):
	
	while stepsTaken < walkAmount:
		walkerPos.x += randi_range(-8,8)
		walkerPos.y += randi_range(-8,8)
		walkerPos += direction * 2
		
		#### GO THROUGH, SEE IF IT'S TOO CLOSE TO OTHER POINTS
		var tooClose := false
		for pos in turnPoints:
			if not tooClose:
				if grid.getGridDistanceOfCoords(walkerPos, pos) < 16:
					tooClose = true
				
		#### AFTER CHECKING EXISTING ROOM POSITIONS
		if not tooClose:
			
			turnPoints.append(walkerPos)
			change_direction()
			faultyStepsCount = 0
		else:
			faultyStepsCount += 1
		
		if faultyStepsCount > 6:
			change_direction()
		
		stepsTaken += 1
	
	prints("turning points, walker 2: ", turnPoints)			
	return turnPoints		
	
	

#### THIS FUNCTION TURNS THE PATH WALKER AROUND
#### IT ALSO
func change_direction():
	var distX := 0
	var distY := 0
				
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.shuffle()
	
	var validDirection := false
	for dir in directions:
		if not validDirection:
			var targetPosition = walkerPos + dir
			distX = abs(targetPosition.x)
			distY = abs(targetPosition.y)
			
			if distX <= 40 and distY <= 20:
				direction = dir
				validDirection = true
			else:
				pass
	
	#### ENFORCE MAP BORDERS
	while distX >= 40:
		if walkerPos.x >= 0:
			walkerPos.x -= 1
		else:
			walkerPos.x += 1
		distX -= 1
		
	while distY >= 20:
		if walkerPos.y >= 0:
			walkerPos.y -= 1
		else:
			walkerPos.y += 1
		distY -= 1
	
	return
				
