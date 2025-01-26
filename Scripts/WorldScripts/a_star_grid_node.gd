extends Node2D



var world:Node = null
var grid:Node = null

var aStarGrid := AStarGrid2D.new()
var aStarManhattan := AStarGrid2D.new()

@export var debugKeepDisposables := false


func setup(world):
	self.world = world
	self.grid = world.grid
	
	aStarGrid.region = Rect2i(-300,-300, 600,600)
	aStarGrid.cell_size = Vector2i(32,32)
	aStarGrid.offset = Vector2i(16,16)
	aStarGrid.update()
	
	setupManhattan()
	#setupGrid()
	
	
	
func setupGrid():
	#aStarGrid.region = Rect2i(-300,-300, 600,600)
	#aStarGrid.cell_size = Vector2i(32,32)
	#aStarGrid.offset = Vector2i(16,16)
	
	#aStarGrid.default_compute_heuristic = AStarGrid2D.h
	#aStarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_
	
	#setupManhattan()
	
	#### TRYING: SET SOLID POINTS HERE
	var walls = grid.wallTiles
	for wallTile in walls:
		#showSolidTile(wallTile)
		aStarGrid.set_point_solid(wallTile, true)
		
	for tile in grid.voidTiles:
		aStarGrid.set_point_solid(tile, true)
		
	aStarGrid.update()
	
	

func setupManhattan():
	aStarManhattan.region = Rect2i(-300,-300, 600,600)
	aStarManhattan.cell_size = Vector2i(32,32)
	aStarManhattan.offset = Vector2i(16,16)
	aStarManhattan.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	aStarManhattan.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	aStarManhattan.update()
	
	

func passTurn():
	
	if debugKeepDisposables:
		return
		
	for node in $Disposables.get_children():
		node.queue_free()
		
	
func createPathBetween(creature, target):
			
	var path = aStarGrid.get_point_path(creature.gridPosition, target.gridPosition )
	var debugLine:Line2D = createDebugLine(path)
	
	return debugLine




func createDebugLine(path) -> Line2D:
	
	var debugLine: Line2D = load("res://Scenes/UI/DebugLine.tscn").instantiate()
	$Disposables.add_child(debugLine)
	debugLine.points = []
	for point in path:
		#prints("points:",point)
		debugLine.add_point(point)
	return debugLine



func createSimplePath(start: Vector2i, end:Vector2i):
	
	var path = aStarGrid.get_point_path(start, end )
	var debugPath := []
	
	for coord in path:
		debugPath.append(coord)
	createDebugLine(debugPath)
	
	return path
	
	
func createPathManhattan(start: Vector2i, end:Vector2i):
	
	var path = aStarManhattan.get_point_path(start, end )
	var debugPath := []
	
	for coord in path:
		debugPath.append(coord)
	createDebugLine(debugPath)
	
	return path

#assert(path.size() != 0, "ERROR EMPTY PATH")
	
func showSolidTile(tilePos):	
	
	var debugSprite = load("res://Scenes/UI/DebugSprite.tscn").instantiate()
	add_child(debugSprite)
	debugSprite.position = tilePos * 32 + Vector2i(16,16)
	
	
