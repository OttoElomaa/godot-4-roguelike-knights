extends Node


var player:Node = null
var grid:Node = null



func setup(player):
	self.player = player
	self.grid = player.grid
	
	
	
func _process(delta: float) -> void:
	
	if States.GameState == States.InputStates.EXPLORE:
		processMovement()
		
		
	
func processMovement():
	
	if Input.is_action_just_pressed("ui_up"):
		if grid.is_tile_empty(player.gridPosition + Vector2i.UP):
			move(Vector2i.UP)
			player.passTurn()
			
	elif Input.is_action_just_pressed("ui_down"):
		if grid.is_tile_empty(player.gridPosition + Vector2i.DOWN):
			move(Vector2i.DOWN)
			player.passTurn()
			
	elif Input.is_action_just_pressed("ui_left"):
		if grid.is_tile_empty(player.gridPosition + Vector2i.LEFT):
			move(Vector2i.LEFT)
			player.passTurn()
			
	elif Input.is_action_just_pressed("ui_right"):
		if grid.is_tile_empty(player.gridPosition + Vector2i.RIGHT):
			move(Vector2i.RIGHT)
			player.passTurn()
			
			
			
func move(vector):
	
	var tiles = get_tree().get_first_node_in_group("tilecontroller")
	
	player.gridPosition += vector
	tiles.placeGridObjectOnMap(player, player.gridPosition)
