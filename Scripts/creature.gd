extends Node2D

class_name Creature


var world:Node = null
var grid:Node = null
var aStarGrid:AStarGrid2D = null
var player:Node = null

var gridPosition := Vector2i.ZERO
#var target:Node = null

@export var isEnemy := true
@export var isPlayer := false
@export var creatureName := ""	


#### FOR MOVEMENT ANIMATION
var newPos:Vector2 = Vector2i.ZERO
var t := 0.0
var isMoving := false

var isOverworld := false

@onready var movementComponent := $CreatureMovement

var stats:
	get:
		return $Stats


	
	
func setup(world:Node):
	
	self.world = world
	setupHelp()
	



func setupHelp():
	
	self.grid = world.grid
	self.player = world.player
	
	$Stats.setup(self)
	$StatusEffects.setup(self)
	
	$HealthBar.setup(self)
	
	$CreatureMovement.setup(self)
	$AnimationComponent.setup(self)
	
	for skill in $Skills.get_children():
		skill.setup(self)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	
	
	
	
func _physics_process(delta: float) -> void:
	
	if not world:
		return
	elif world.isMapKilled:
		return
	
	if Input.is_action_just_pressed("P"):
		creatureMove()
	
	if isMoving:
		
		t += delta * 2.5
		position = position.lerp(newPos, t)
		
		if position == newPos:
			prints("movement goal reached, ", creatureName)
			isMoving = false	
			t = 0.0	
	
	
func creatureMove():
	
	var movementTarget = world.player
	
	#### ENEMIES VERY FAR FROM PLAYER WILL NOT CHASE PLAYER
	#if world.grid.getGridDistance(self, movementTarget) > 7:
		#return
	
	#### ADJACENT CREATURES DON'T MOVE	
	if world.grid.getGridDistance(self, movementTarget) < 2:
		return
	
	#### CREATURE CAN MOVE IN THESE DIRECTIONS
	var allowedDirs := [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT, Vector2i.RIGHT]
	allowedDirs.append_array([ Vector2i(1,1),Vector2i(-1,-1),Vector2i(-1,1),Vector2i(1,-1) ] )

	#### GET A LINE OF THE PATH FROM SELF TO TARGET (PLAYER)
	var line: Line2D = world.aStar.createPathBetween(self, movementTarget)
	
	#### DEBUG: SHOW/HIDE LINE
	line.hide()
	
	#assert(line.points.size() < 2, "WHAT THE-- PATHING ERROR")
	if line.points.size() < 2:
		return
	
	#### COMPARE TARGET POSITION TO CREATURE POSITIONS
	#### ROUND FROM 0.777... TO 1
	var dir = position.direction_to(line.points[1])
	dir = Vector2i(round(dir.x), round(dir.y))
	
	#print(dir)
	var creaturePositions : Array = grid.getCreatureTiles()
	
	if dir in allowedDirs:
		var targetGridPos = gridPosition + Vector2i(dir)
		
		#### IF TARGET POSITION IS OCCUPIED BY CREATURE, DON'T MOVE
		if targetGridPos in creaturePositions:
			return
			
		else:
			movementComponent.move(dir)
			line.remove_point(0)
			
	

func checkValidity() -> bool:
	if not is_instance_valid(self):
		return false
	if self.is_queued_for_deletion():
		return false
	return true
	
	




func startTurn():
	
	
	if isPlayer and not isOverworld:
		if gridPosition == world.exitGridPos:
			print("EXIT REACHEDDDDDDDD")
			world.resetLevel()
			return
			
	if not world.player.checkValidity():
		return
	if not self.checkValidity():
		return	
	
	$HealthBar.updateVisual(stats.health, stats.guard)
	if isPlayer:
		world.updateVisuals()
		world.ui.updateVisualsOnTurn()
		
	
	prints(creatureName, " valid, takes action")
	#### TICK COOLDOWNS ETC ON-TURN EFFECTS ON SKILL NODES
	for skill in getSkills():
		var pointlessReturn = skill.passTurn()
		#if isPlayer:
		prints("tick! ", skill.getCooldown())
	
	$StatusEffects.tickStatus()
	
	if $StatusEffects.isStunned:
		finishTurn()
	
	#### PLAYER PASSES TURN AFTER TAKING ACTION, SO DO NOTHING NOW
	if isPlayer:
		return
		
	
	#### DON'T DO ANYTHING IF DEAD
	if $Stats.health.current <= 0:
		return
	
	#### DON'T DO ANYHTHING IF AWAY FROM PLAYER
	#### SO ALL ALLIES/ENEMIES/ETC FREEZE WHEN FAR AWAY
	if world.grid.getGridDistance(self, player) > 12:
		finishTurn()
		return
	
	###################################################
	#### PICK TARGET
	#chooseTarget()
	#### TRY TO USE A SKILL
	if useSkills():
		finishTurn()
		return
		
	#### TRY TO MOVE	
	creatureMove()
	finishTurn()
	


func finishTurn():
	world.callNextTurnAction()



func useSkills() -> bool:
	
	for skill in $Skills.get_children():
		if skill.activate() == true:
			return true
	return false


func move(vector):
	#tiles.placeGridObjectOnMap(self, gridPosition)
	
	pass
	#movementComponent.move()
	
	#gridPosition += Vector2i(vector)
	#newPos = grid.grid_to_world(gridPosition)
	#isMoving = true
	#$SpriteAnimations.play("MovementWobble")


func handleMove(dir:Vector2i):
	
	$CreatureMovement.handleMove(dir)
	

func takeDamage(amount:int):
	
	$Stats.takeDamage(amount)
	$AnimationComponent.playMeleeHit()


func handlePhysicalHit(damage:int):
	$Stats.handlePhysicalHit(damage)


func recoverHealth(amount: int):
	$Stats.recoverHealth(amount)
	#$AnimationComponent.playMeleeHit()


func hasFullHealth():
	var he = stats.health
	return he.current >= he.max	


func addStatus(status:Node):
	$StatusEffects.addStatus(status)



#### THIS RECEIVES A STATRESOURCE, STATS.HEALTH, WITH VALUES 'CURRENT' AND 'MAX'
func updateHealthBar(health):
	$HealthBar.updateVisual(health, stats.guard)


func playMovementWobble():
	$SpriteAnimations.play("MovementWobble")
	
	
	
#########################################################################
	
func getNavigator():
	return $NavigationAgent2D
	

func getSkills():
	return $Skills.get_children()


func getHealth():
	return $Stats.health.current


func _on_mouse_area_mouse_entered() -> void:
	
	if not world:
		return
	if world.isOverworld:
		return
	
	prints("Mouse entered: ", creatureName)
	world.ui.showMouseLookCreature(self)
