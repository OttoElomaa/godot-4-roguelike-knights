extends Node2D



var game:Node = null
var grid:Node = null
var aStarGrid:AStarGrid2D = null
var player:Node = null

var gridPosition := Vector2i.ZERO

@export var creatureName := ""	
	

func roomSetup(room):
	
	var tree = room.get_tree()
	self.game = tree.root.get_node("GameMain")
	self.grid = game.getGrid()
	self.player = game.getPlayer()
	#self.aStarGrid = game.getAStar()
	
	
func mySetup():
	pass
	#self.game = game
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("P"):
		pathStuff()
	
	
	
	
	
func pathStuff():

	#### GET A LINE OF THE PATH FROM SELF TO TARGET (PLAYER)
	var line: Line2D = game.pathStuff(self, game.getPlayer())
	
	#### IF ADJACENT TO TARGET, DON'T MOVE
	if line.points.size() < 3:
		line.hide()
		return
	
	var creaturePositions : Array = grid.getCreatureTiles()
	var dir = position.direction_to(line.points[1])
	
	#### COMPARE TARGET POSITION TO CREATURE POSITIONS
	match dir:
		Vector2.UP,Vector2.DOWN,Vector2.LEFT, Vector2.RIGHT:
			var targetGridPos = gridPosition + Vector2i(dir)
			
			#### IF TARGET POSITION IS OCCUPIED BY CREATURE, DON'T MOVE
			if targetGridPos in creaturePositions:
				return
			else:
				move(dir)
				
	line.hide()
	


func passTurn():
	pathStuff()	
	


func move(vector):
	
	var tiles = get_tree().get_first_node_in_group("tilecontroller")
	
	gridPosition += Vector2i(vector)
	tiles.placeGridObjectOnMap(self, gridPosition)
	
