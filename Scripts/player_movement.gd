extends Node


var player:Node = null
var grid:Node = null
var world:Node = null

var tween:Tween = null
var oldPos:Vector2 = Vector2i.ZERO
var newPos:Vector2 = Vector2i.ZERO

var t := 0.0
var isMoving := false

var holdingKey := false
var movementDir := Vector2i.ZERO

@export var isOverworld := false

signal movementDone


func setup(player):
	self.player = player
	self.grid = player.grid
	

func overworldSetup(world):
	self.world = world
	player = get_parent()
	self.grid = world.grid

func dungeonSetup():
	self.world = player.world
	self.grid = world.grid
	
func _process(delta: float) -> void:
	
	#### MOVEMENT UNDERWAY, DON'T ACCEPT NEW INPUT
	if isMoving:
		return
	#### MOVEMENT ONLY IN EXPLORE STATE
	if States.GameState == States.InputStates.EXPLORE:
		processMovement()
	

func _physics_process(delta: float) -> void:
	
	#### FOR NOW, ONLY FOR PLAYER
	if not player:
		return
	
	#### MOVEMENT UNDERWAY FROM ONE TILE TO OTHER
	if isMoving:
		t += delta * 2.5
		player.position = player.position.lerp(newPos, t)
		
		#### MOVEMENT COMPLETED RIGHT NOW
		if player.position == newPos:
			resolveCompletedMovement()
	
			
	#### PLAYER STOPPED PRESSING MOVEMENT
	if Input.is_action_just_released("ui_up"):
		holdingKey = false
	elif Input.is_action_just_released("ui_down"):
		holdingKey = false
	elif Input.is_action_just_released("ui_left"):
		holdingKey = false
	elif Input.is_action_just_released("ui_right"):
		holdingKey = false


#### MOVEMENT DONE, RESOLVE ITS RESULT
func resolveCompletedMovement():
	print("movement goal reached")
	isMoving = false	
	t = 0.0
	
	if holdingKey:
		handleMove(movementDir)
	
	if not isOverworld:
		world.ui.addMessage("You take a step", Color.WHITE)	
	player.passTurn()

		
	
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
			
			
			
func handleMove(dir):
	
	if not grid.is_tile_empty(player.gridPosition + dir):
		return
		
	move(dir)
	holdingKey = true
	movementDir = dir

			
func move(vector):
	
	#### MOVE TOWARD NEW POSITION WHILE ISMOVING (SEE PHYSICS PROCESS)
	oldPos = grid.grid_to_world(player.gridPosition)
	player.gridPosition += vector
	
	newPos = grid.grid_to_world(player.gridPosition)
	isMoving = true
	player.playMovementWobble()
	
	
	
