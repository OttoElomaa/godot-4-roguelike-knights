extends Node


const DIRECTIONS = [Vector2i.RIGHT, Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN]


var walkerPos = Vector2i.ZERO
var direction = Vector2i.RIGHT

var stepsTaken := 0
var turnPoints := []
var roomsPlaced := 0

#### TRACK HOW MANY UNSUCCESSFUL STEPS AFTER LAST TURN
var faultyStepsCount := 0

var distX := 0
var distY := 0


class TurningPoint:
	var gridPosition := Vector2i.ZERO
	var hasRoom := false
	
	func _init(coords:Vector2i, hasRoom:bool) -> void:
		self.gridPosition = coords
		self.hasRoom = hasRoom
		


func walkMiniworld(walkAmount:int):
	
	for i in range(10):
		walkMiniTwo(walkAmount)
	return turnPoints
		

func walkMiniTwo(walkAmount:int):
	walkerPos.x = randi_range(10, 20)
	walkerPos.y = randi_range(10, 20)
	
	#### WALK FOR THE SPECIFIED AMOUNT OF STEPS
	while stepsTaken < walkAmount:
		
		prints("successful step at ", walkerPos)
		
		#### ADD TO ROOM POSITIONS, STEP'S BEEN TAKEN
		turnPoints.append(TurningPoint.new(walkerPos, true))
		stepsTaken += 1
		roomsPlaced += 1
		faultyStepsCount = 0
		
		#### MOVE WALKER BY RANDOM AMOUNT, THEN GO AWAY FROM NEAREST ROOM
		walkerPos.x += randi_range(-2,2)
		walkerPos.y += randi_range(-2,2)
		goAwayFromPoints(walkerPos)
			
		#### NORMAL STEP ACTION
		walkerPos += direction * randi_range(1,3)
		
		#### TRY TO MOVE WALKER BACK TO WITHIN BOUNDARIES	
		distX = abs(walkerPos.x)
		distY = abs(walkerPos.y)
		if restoreToWithinBoundary():
			walkerPos.x += randi_range(-5,5)
			walkerPos.y += randi_range(-5,5)
		
	prints("turning points, walker 2: ")
	for p in turnPoints:
		print(p.gridPosition)			
	return turnPoints		







func walk(walkAmount:int):
	
	#### MULTIPLE WALKS???
	for i in range(5):
		walkTwo(walkAmount)
	return turnPoints
	
	
	
func walkTwo(walkAmount):
	
	walkerPos.x = randi_range(-5,5)
	walkerPos.y = randi_range(-5,5)
	
	#### WALK FOR THE SPECIFIED AMOUNT OF STEPS
	while stepsTaken < walkAmount:
		
		#### QUIT IF WE GOT ENOUGH ROOMS
		if roomsPlaced > 6:
			return turnPoints
		
		#### GO THROUGH, SEE IF IT'S TOO CLOSE TO OTHER POINTS
		var tooClose := false
		for point:TurningPoint in turnPoints:
			if not tooClose:
				if point.hasRoom:
					var dist = GridTools.getGridDistanceOfCoords(walkerPos, point.gridPosition)
					if dist < 14:
						prints("too close, distance: ", dist)
						tooClose = true
				
		#### IF NOT TOO CLOSE TO EXISTING ROOM POSITIONS
		if not tooClose:
			prints("successful step at ", walkerPos)
			
			#### ADD TO ROOM POSITIONS, STEP'S BEEN TAKEN
			turnPoints.append(TurningPoint.new(walkerPos, true))
			stepsTaken += 1
			roomsPlaced += 1
			faultyStepsCount = 0
			
			#### MOVE WALKER BY RANDOM AMOUNT, THEN GO AWAY FROM NEAREST ROOM
			walkerPos.x += randi_range(-12,12)
			walkerPos.y += randi_range(-12,12)
			goAwayFromPoints(walkerPos)
			
		#### IF TOO CLOSE TO EXISTING ROOM POSITIONS
		else:
			faultyStepsCount += 1
		
		#### NORMAL STEP ACTION
		goAwayFromPoints(walkerPos)
		walkerPos += direction
		
		if faultyStepsCount > 4:
			prints("faulty step, course correcting now at: ", walkerPos)
			#goAwayFromPoints(walkerPos)
			#walkerPos += direction * 3
			walkerPos.x += randi_range(-5,5)
			walkerPos.y += randi_range(-5,5)
			
			faultyStepsCount = 0
			stepsTaken += 1
			turnPoints.append(TurningPoint.new(walkerPos, false))
		
		#### TRY TO MOVE WALKER BACK TO WITHIN BOUNDARIES	
		distX = abs(walkerPos.x)
		distY = abs(walkerPos.y)
		if restoreToWithinBoundary():
			walkerPos.x += randi_range(-5,5)
			walkerPos.y += randi_range(-5,5)
		
	prints("turning points, walker 2: ")
	for p in turnPoints:
		print(p.gridPosition)			
	return turnPoints		


func step():
	pass

				

#### MOVE AWAY FROM THE POINT CLOSEST TO WALKER POSITION
func goAwayFromPoints(pos:Vector2i):
	var closestPoint := Vector2i.ZERO
	var shortestDistance := 1000
	
	if turnPoints.size() == 0:
		return direction
	
	#### GET CLOSEST POINT TO CURRENT WALKER POSITION	
	for point in turnPoints:
		var pointPos = point.gridPosition
		if pos.distance_to(pointPos) < shortestDistance:
			closestPoint = pointPos
			shortestDistance = pos.distance_to(pointPos)
			
	var dir = Vector2(pos).direction_to(Vector2(closestPoint))
	dir.x = round(dir.x)
	dir.y = round(dir.y)
	
	prints("closest room pos: ", closestPoint)
	prints("direction to it: ", dir)
	
	var oppositesDict := {}
	oppositesDict[Vector2.UP] = Vector2.DOWN
	oppositesDict[Vector2.DOWN] = Vector2.UP
	oppositesDict[Vector2.LEFT] = Vector2.RIGHT
	oppositesDict[Vector2.RIGHT] = Vector2.LEFT
	
	oppositesDict[Vector2(-1,-1)] = Vector2(1,1)
	oppositesDict[Vector2(1,1)] = Vector2(-1,-1)
	oppositesDict[Vector2(-1,1)] = Vector2(1,-1)
	oppositesDict[Vector2(1,-1)] = Vector2(-1,1)
	
	if dir in oppositesDict.keys():
		direction = Vector2i( oppositesDict[dir] )
	


#### ENFORCE MAP BORDERS
func restoreToWithinBoundary():	
	
	var maxDistX := 40
	var maxDistY := 30
	var count := 0
	
	prints("Trying restore, ", distX ,", ", distY)
	while distX >= maxDistX + 5:
		if walkerPos.x >= 0:
			walkerPos.x = maxDistX
			direction.x = -1
		else:
			walkerPos.x = maxDistX * -1
			direction.x = 1
		distX = maxDistX
		
		count += 1
		prints("restoring order: ", walkerPos)
		
	while distY >= maxDistY + 5:
		if walkerPos.y >= 0:
			walkerPos.y = maxDistY
			direction.y = -1
		else:
			walkerPos.y = maxDistY * -1
			direction.y = 1
		distY = maxDistY
		
		count += 1
		prints("restoring order: ", walkerPos)
	
	#### DID BOUNDARY BOX ENFORCEMENET HAPPEN?
	if count > 0:
		return true
	return false
