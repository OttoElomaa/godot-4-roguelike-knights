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
	
	
	
func continuePlayerMovement():
	handleMove(movementDir)

			
func handleMove(dir):
	
	if not grid.is_tile_empty(creature.gridPosition + dir):
		return
	
	var idk = move(dir)
	movementDir = dir
	
	if creature.isPlayer and not creature.isOverworld:
		$MovementTurnTimer.start()
		world.ui.addMessage("%s takes a step" % creature.creatureName, Color.WHITE)
			
	#### BOONS
	creature.triggerBoonSelfStep()
	
	#### PASS THE TURN HERE, IF PLAYER
	if creature.isPlayer and not creature.isOverworld:		
		world.callNextTurnAction()	
			
			
			
func move(vector) -> bool:
	
	#### PHYSICS ISMOVING STUFF
	oldPos = GridTools.gridToWorld(creature.gridPosition)
	#### SET NEW GRID POSITION
	creature.gridPosition += vector
	
	
	#### ANIMATION - MOVE TOWARD NEW POSITION WHILE ISMOVING (SEE PHYSICS PROCESS)
	newPos = GridTools.gridToWorld(creature.gridPosition)
	isMoving = true
	creature.playMovementWobble()
	return true
	

#### PLAYER TURN CONTROL	
func _on_movement_turn_timer_timeout() -> void:
	creature.get_node("MovementInput").resolvePlayerMovement()
