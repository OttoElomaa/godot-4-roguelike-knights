extends Node



var isMoving := false
var holdingKey := false

var player:Creature = null


func setup(player):

	self.player = player



func _process(delta: float) -> void:
	
	if not player:
		return
	elif player.world.isMapKilled:
		return
	
	#### PLAYER STOPPED PRESSING MOVEMENT
	if Input.is_action_just_released("ui_up"):
		holdingKey = false
	elif Input.is_action_just_released("ui_down"):
		holdingKey = false
	if Input.is_action_just_released("ui_left"):
		holdingKey = false
	elif Input.is_action_just_released("ui_right"):
		holdingKey = false
		
	if Input.is_action_just_released("num7"):
		holdingKey = false
	elif Input.is_action_just_released("num3"):
		holdingKey = false
	if Input.is_action_just_released("num9"):
		holdingKey = false
	elif Input.is_action_just_released("num1"):
		holdingKey = false
	
	
	#### MOVEMENT UNDERWAY, DON'T ACCEPT NEW INPUT
	if isMoving:
		return
	#### MOVEMENT ONLY IN EXPLORE STATE
	if States.GameState == States.InputStates.EXPLORE:
		processMovement()
	
	
	
func processMovement():
	
	#### JUST PRESSED MOVEMENT KEY
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
	
	holdingKey = true
	player.movementComponent.handleMove(dir)
	
	
#### MOVEMENT DONE, RESOLVE ITS RESULT
func resolvePlayerMovement():
	
	#### RESOLVE THE PREVIOUS, NOW COMPLETED MOVEMENT
	#player.movementComponent.resolveCompletedMovement()
	
	#### IF PLAYER STILL PRESSING MOVE KEY, START A NEW MOVEMENT
	if holdingKey:
		player.movementComponent.continuePlayerMovement()
	
	if not player.isOverworld:
		player.world.ui.addMessage("You take a step", Color.WHITE)	
	
