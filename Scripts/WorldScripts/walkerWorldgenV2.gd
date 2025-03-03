extends Node


const DIRECTIONS = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]

var walkerPos = Vector2i.ZERO
var direction = Vector2i.RIGHT

var stepsTaken := 0
var turnPoints := []
#### TRACK HOW MANY UNSUCCESSFUL STEPS AFTER LAST TURN
var faultyStepsCount := 0

var distX := 0
var distY := 0


class turningPoint:
	var position := Vector2i.ZERO
	var hasRoom := false
	
	func _init(hasRoom:bool) -> void:
		self.hasRoom = hasRoom
		

func walk(walkAmount, grid):
	
	while stepsTaken < walkAmount:
		
		#### GO THROUGH, SEE IF IT'S TOO CLOSE TO OTHER POINTS
		var tooClose := false
		for pos in turnPoints:
			if not tooClose:
				var dist = grid.getGridDistanceOfCoords(walkerPos, pos)
				if dist < 16:
					prints("too close, distance: ", dist)
					tooClose = true
				
		#### IF NOT TOO CLOSE TO EXISTING ROOM POSITIONS
		if not tooClose:
			
			#### ADD TO ROOM POSITIONS, STEP'S BEEN TAKEN
			turnPoints.append(walkerPos)
			stepsTaken += 1
			faultyStepsCount = 0
			
			#### MOVE WALKER BY RANDOM AMOUNT, THEN GO AWAY FROM NEAREST ROOM
			walkerPos.x += randi_range(-12,12)
			walkerPos.y += randi_range(-12,12)
			goAwayFromPoints(walkerPos)
			
		#### IF TOO CLOSE TO EXISTING ROOM POSITIONS
		else:
			faultyStepsCount += 1
			walkerPos += direction
		
		if faultyStepsCount > 4:
			direction = goAwayFromPoints(walkerPos)
			walkerPos += direction
			faultyStepsCount += 1
			stepsTaken += 1
		
		#### TRY TO MOVE WALKER BACK TO WITHIN BOUNDARIES	
		distX = abs(walkerPos.x)
		distY = abs(walkerPos.y)
		if restoreToWithinBoundary():
			walkerPos.x += randi_range(-5,5)
			walkerPos.y += randi_range(-5,5)
		
		if turnPoints.size() > 6:
			return turnPoints
		
	prints("turning points, walker 2: ", turnPoints)			
	return turnPoints		



#### ENFORCE MAP BORDERS
func restoreToWithinBoundary():	
	
	var maxDistX := 40
	var maxDistY := 30
	var count := 0
	
	prints("Trying restore, ", distX ,", ", distY)
	while distX >= maxDistX + 5:
		if walkerPos.x >= 0:
			walkerPos.x = maxDistX
		else:
			walkerPos.x = maxDistX * -1
		distX = 55
		
		count += 1
		prints("restoring order: ", walkerPos)
		
	while distY >= maxDistY + 5:
		if walkerPos.y >= 0:
			walkerPos.y = maxDistY
		else:
			walkerPos.y = maxDistY * -1
		distY = 35
		
		count += 1
		prints("restoring order: ", walkerPos)
	
	#### DID BOUNDARY BOX ENFORCEMENET HAPPEN?
	if count > 0:
		return true
	return false

				

#### MOVE AWAY FROM THE POINT CLOSEST TO WALKER POSITION
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
	
	#### MOVE AWAY FROM IT
	match dir:
		Vector2.UP, Vector2(1, -1), Vector2(-1, -1):
			return Vector2i.DOWN
		Vector2.DOWN, Vector2(1, 1), Vector2(-1, 1):
			return Vector2i.UP
		Vector2.LEFT:
			return Vector2i.RIGHT
		Vector2.RIGHT:
			return Vector2i.LEFT
	
	#distX = walkerPos.x
	#distY = walkerPos.y
	#restoreToWithinBoundary()
			
	return direction
