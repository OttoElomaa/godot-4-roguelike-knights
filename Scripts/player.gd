extends Node2D

var game: Node = null
var grid: Node = null

var gridPosition := Vector2i.ZERO

@export var creatureName := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func setup(game):
	self.game = game
	grid = game.getGrid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if States.GameState == States.InputStates.EXPLORE:
		processExplore()
	
	

func processExplore():
	if Input.is_action_just_pressed("ui_up"):
		if grid.is_tile_empty(gridPosition + Vector2i.UP):
			move(Vector2i.UP)
			passTurn()
			
	elif Input.is_action_just_pressed("ui_down"):
		if grid.is_tile_empty(gridPosition + Vector2i.DOWN):
			move(Vector2i.DOWN)
			passTurn()
			
	elif Input.is_action_just_pressed("ui_left"):
		if grid.is_tile_empty(gridPosition + Vector2i.LEFT):
			move(Vector2i.LEFT)
			passTurn()
			
	elif Input.is_action_just_pressed("ui_right"):
		if grid.is_tile_empty(gridPosition + Vector2i.RIGHT):
			move(Vector2i.RIGHT)
			passTurn()




func move(vector):
	
	var tiles = get_tree().get_first_node_in_group("tilecontroller")
	
	gridPosition += vector
	tiles.placeGridObjectOnMap(self, gridPosition)



func passTurn():
	game.passTurn()
