extends Node2D


var game:Node = null
var grid:Node = null

var aStarGrid := AStarGrid2D.new()


func setup(game) -> void:
	self.game = game
	self.grid = game.grid
	
	
func setupGrid():
	aStarGrid.region = Rect2i(0,0, 100,100)
	aStarGrid.cell_size = Vector2i(32,32)
	aStarGrid.offset = Vector2i(16,16)
	aStarGrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	aStarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	aStarGrid.update()



func passTurn():
	for node in $Disposables.get_children():
		node.queue_free()
	
	
	
func pathStuff(creature, target):

	var walls = grid.getAllWallTiles()
	for wallTile in walls:
		#showSolidTile(wallTile)
		aStarGrid.set_point_solid(wallTile, true)
			
	var debugLine: Line2D = load("res://Scenes/DebugLine.tscn").instantiate()
	$Disposables.add_child(debugLine)
	
	var path = aStarGrid.get_point_path(creature.position / 32, target.gridPosition )
	
	debugLine.points = []
	for point in path:
		#prints("points:",point)
		debugLine.add_point(point)
	
	return debugLine



func showSolidTile(tilePos):	
	
	var debugSprite = load("res://Scenes/DebugSprite.tscn").instantiate()
	add_child(debugSprite)
	debugSprite.position = tilePos * 32 + Vector2i(16,16)
