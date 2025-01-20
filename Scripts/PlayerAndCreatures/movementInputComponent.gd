extends Node



var isMoving := false
var holdingKey := false

var player:Creature = null


func setup(player):

	self.player = player



func _process(delta: float) -> void:
	
	#### MOVEMENT UNDERWAY, DON'T ACCEPT NEW INPUT
	if isMoving:
		return
	#### MOVEMENT ONLY IN EXPLORE STATE
	if States.GameState == States.InputStates.EXPLORE:
		processMovement()
	
	
	#### PLAYER STOPPED PRESSING MOVEMENT
	if Input.is_action_just_released("ui_up"):
		holdingKey = false
	elif Input.is_action_just_released("ui_down"):
		holdingKey = false
	elif Input.is_action_just_released("ui_left"):
		holdingKey = false
	elif Input.is_action_just_released("ui_right"):
		holdingKey = false
		
		
		
func processMovement():
	
	if Input.is_action_just_pressed("ui_up"):
		handleMove(Vector2i.UP)
				
	elif Input.is_action_just_pressed("ui_down"):
		handleMove(Vector2i.DOWN)
					
	elif Input.is_action_just_pressed("ui_left"):
		handleMove(Vector2i.LEFT)
				
	elif Input.is_action_just_pressed("ui_right"):
		handleMove(Vector2i.RIGHT)
		
	
	elif Input.is_action_just_pressed("num7"):
		handleMove(Vector2i(-1,-1))
	elif Input.is_action_just_pressed("num9"):
		handleMove(Vector2i(1,-1))
	elif Input.is_action_just_pressed("num1"):
		handleMove(Vector2i(-1,1))
	elif Input.is_action_just_pressed("num3"):
		handleMove(Vector2i(1,1))



func handleMove(dir:Vector2i):
	
	player.movementComponent.handleMove(dir)
	
	
#### MOVEMENT DONE, RESOLVE ITS RESULT
func resolveCompletedMovement():
	
	player.movementComponent.resolveCompletedMovement()
	

	if holdingKey:
		player.movementComponent.handlePlayerMove()
	
	if not player.isOverworld:
		player.world.ui.addMessage("You take a step", Color.WHITE)	
	
