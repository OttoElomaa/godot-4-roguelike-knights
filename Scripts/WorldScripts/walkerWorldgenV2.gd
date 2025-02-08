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
		#walkerPos += direction * randi_range(1,2)
		walkerPos.x += randi_range(-2,2)
		walkerPos.y += randi_range(-2,2)
		
		#### GO THROUGH, SEE IF IT'S TOO CLOSE TO OTHER POINTS
		var tooClose := false
		for pos in turnPoints:
			if not tooClose:
				if grid.getGridDistanceOfCoords(walkerPos, pos) < 16:
					tooClose = true
				
		#### AFTER CHECKING EXISTING ROOM POSITIONS
		if not tooClose:
			
			turnPoints.append(walkerPos)
			stepsTaken += 1
			goAwayFromPoints(walkerPos)
			faultyStepsCount = 0
		else:
			faultyStepsCount += 1
		
		if faultyStepsCount > 4:
			direction = goAwayFromPoints(walkerPos)
			walkerPos += direction
			faultyStepsCount = 0
			stepsTaken += 1
		
		
	
	prints("turning points, walker 2: ", turnPoints)			
	return turnPoints		


func restoreToWithinBoundary(distX:int, distY:int):	
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
	prints("restoring order: ", walkerPos)
	

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
	
	restoreToWithinBoundary(distX, distY)
	
	return
				


func goAwayFromPoints(pos:Vector2i):
	var closestPoint := Vector2i.ZERO
	var shortestDistance := 1000
	
	if turnPoints.size() == 0:
		return direction
	
	#### GET CLOSEST POINT TO CURRENT WALKER POSITION	
	for point in turnPoints:
		if pos.distance_to(point) < shortestDistance:
			closestPoint = point
			shortestDistance = pos.distance_to(point)
			
	var dir = Vector2(pos).direction_to(Vector2(closestPoint))
	dir.x = round(dir.x)
	dir.y = round(dir.y)
	
	prints("closest room pos: ", closestPoint)
	prints("direction to it: ", dir)
	
	match dir:
		Vector2.UP, Vector2(1, -1), Vector2(-1, -1):
			return Vector2i.DOWN
		Vector2.DOWN, Vector2(1, 1), Vector2(-1, 1):
			return Vector2i.UP
		Vector2.LEFT:
			return Vector2i.RIGHT
		Vector2.RIGHT:
			return Vector2i.LEFT
	
	restoreToWithinBoundary(walkerPos.x, walkerPos.y)
			
	return direction
