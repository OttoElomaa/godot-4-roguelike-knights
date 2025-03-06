extends Node



var isMoving := false
var holdingKey := false

var player:Creature = null


func setup(player):

	self.player = player



func _process(delta: float) -> void:
	
	if not player:
		return
	if not player.world:
		return
	if player.world.isMapKilled:
		return
	
	
	if States.GameState == States.InputStates.EXPLORE:
		
		#### STOP MOVEMENT IF MOVEMENT KEY IS PRESSED
		processExploreRelease()
		
		#### MOVEMENT UNDERWAY, DON'T ACCEPT NEW INPUT
		if isMoving:
			return
			
		#### MOVEMENT ONLY IN EXPLORE STATE
		if States.GameState == States.InputStates.EXPLORE:
			processMovementPress()
		
		
	
	
	
func processMovementPress():
	
	var dir := Vector2i.ZERO
	
	#### JUST PRESSED MOVEMENT KEY
	if Input.is_action_just_pressed("ui_up"):
		dir = Vector2i.UP			
	elif Input.is_action_just_pressed("ui_down"):
		dir = Vector2i.DOWN				
	elif Input.is_action_just_pressed("ui_left"):
		dir = Vector2i.LEFT			
	elif Input.is_action_just_pressed("ui_right"):
		dir = Vector2i.RIGHT
		
	#### JUST PRESSED NUMPAD MOVEMENT KEY
	elif Input.is_action_just_pressed("num8"):
		dir = Vector2i.UP
	elif Input.is_action_just_pressed("num2"):
		dir = Vector2i.DOWN					
	elif Input.is_action_just_pressed("num4"):
		dir = Vector2i.LEFT			
	elif Input.is_action_just_pressed("num6"):
		dir = Vector2i.RIGHT
	
	elif Input.is_action_just_pressed("num7"):
		dir = Vector2i(-1,-1)
	elif Input.is_action_just_pressed("num9"):
		dir = Vector2i(1,-1)
	elif Input.is_action_just_pressed("num1"):
		dir = Vector2i(-1,1)
	elif Input.is_action_just_pressed("num3"):
		dir = Vector2i(1,1)
	
	if not dir == Vector2i.ZERO:
		handleMove(dir)



func processExploreRelease():
	#### PLAYER STOPPED PRESSING MOVEMENT
	if Input.is_action_just_released("ui_up"):
		holdingKey = false
	elif Input.is_action_just_released("ui_down"):
		holdingKey = false
	if Input.is_action_just_released("ui_left"):
		holdingKey = false
	elif Input.is_action_just_released("ui_right"):
		holdingKey = false
	
	#### JUST PRESSED NUMPAD MOVEMENT KEY, STRAIGHT MOVEMENT
	if Input.is_action_just_released("num8"):
		holdingKey = false
	elif Input.is_action_just_released("num2"):
		holdingKey = false				
	if Input.is_action_just_released("num4"):
		holdingKey = false			
	elif Input.is_action_just_released("num6"):
		holdingKey = false
	
	#### RELEASED NUMPAD KEY, DIAGONAL MOVEMENT		
	if Input.is_action_just_released("num7"):
		holdingKey = false
	elif Input.is_action_just_released("num3"):
		holdingKey = false
	if Input.is_action_just_released("num9"):
		holdingKey = false
	elif Input.is_action_just_released("num1"):
		holdingKey = false



func handleMove(dir:Vector2i):
	
	holdingKey = true
	player.movementComponent.handleMove(dir)
	
	
	
#### MOVEMENT DONE, RESOLVE ITS RESULT
func resolvePlayerMovement():
	
	States.GameState = States.InputStates.EXPLORE
	#### IF PLAYER STILL PRESSING MOVE KEY, START A NEW MOVEMENT
	if holdingKey:
		player.movementComponent.continuePlayerMovement()
	
		
	
