extends Node


var creature:Node = null
var world:Node = null
var grid:Node = null


var tween:Tween = null
var oldPos:Vector2 = Vector2i.ZERO
var newPos:Vector2 = Vector2i.ZERO

var t := 0.0
var isMoving := false


var movementDir := Vector2i.ZERO

@export var isOverworld := false




func setup(creature):
	self.creature = creature
	self.world = creature.world
	self.grid = world.grid
	

func overworldSetup(world):
	self.world = world
	creature = get_parent()
	self.grid = world.grid


func dungeonSetup():
	self.world = creature.world
	self.grid = world.grid
	
	
		
func _physics_process(delta: float) -> void:
		
	if not world:
		return
	elif world.isMapKilled:
		return
	
	#### MOVEMENT UNDERWAY FROM ONE TILE TO OTHER
	if isMoving:
		t += delta * 2.5
		creature.position = creature.position.lerp(newPos, t)
		
		#### MOVEMENT COMPLETED RIGHT NOW
		if creature.position == newPos:
			resolveCompletedMovement()
	
			

#### MOVEMENT DONE, RESOLVE ITS RESULT
func resolveCompletedMovement():
	
	isMoving = false	
	t = 0.0
	
	#### RESTORE IF BROKEN
	#if creature.isPlayer:
		#creature.get_node("MovementInput").resolvePlayerMovement()
	
	if creature.isPlayer:
		if not isOverworld:
			world.callNextTurnAction()


		

func continuePlayerMovement():
	handleMove(movementDir)

			
func handleMove(dir):
	
	if not grid.is_tile_empty(creature.gridPosition + dir):
		return
	
	move(dir)
	movementDir = dir
	
	if creature.isPlayer:
		$MovementTurnTimer.start()
		if not creature.isOverworld:
			world.ui.addMessage("You take a step", Color.WHITE)

			
func move(vector):
	
	#### MOVE TOWARD NEW POSITION WHILE ISMOVING (SEE PHYSICS PROCESS)
	oldPos = grid.grid_to_world(creature.gridPosition)
	creature.gridPosition += vector
	
	newPos = grid.grid_to_world(creature.gridPosition)
	isMoving = true
	creature.playMovementWobble()
	
	

#### PLAYER TURN CONTROL	
func _on_movement_turn_timer_timeout() -> void:
	creature.get_node("MovementInput").resolvePlayerMovement()
