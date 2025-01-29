extends Node2D

class_name Creature


var world:Node = null
var grid:Node = null
var aStarGrid:AStarGrid2D = null
var player:Node = null

var gridPosition := Vector2i.ZERO
var target:Node = null

@export var isEnemy := true
@export var isPlayer := false
@export var creatureName := ""	


#### FOR MOVEMENT ANIMATION
var newPos:Vector2 = Vector2i.ZERO
var t := 0.0
var isMoving := false

var isOverworld := false

@onready var movementComponent := $CreatureMovement





func roomSetup(room):
	
	var tree = room.get_tree()
	self.world = tree.root.get_node("GameMain/World")
	setupHelp()
	
	
func basicSetup(world):
	
	self.world = world
	setupHelp()
	



func setupHelp():
	
	self.grid = world.getGrid()
	self.player = world.getPlayer()
	
	$HealthComponent.setup(self)
	$Stats.setup(self)
	$CreatureMovement.setup(self)
	
	$AnimationComponent.setup(self)
	
	for skill in $Skills.get_children():
		skill.setup(self)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("P"):
		creatureMove()
	
	
func _physics_process(delta: float) -> void:
	
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
	if world.grid.getGridDistance(self, movementTarget) > 7:
		return
	
	#### ADJACENT CREATURES DON'T MOVE	
	elif world.grid.getGridDistance(self, movementTarget) < 2:
		return
	
	#### CREATURE CAN MOVE IN THESE DIRECTIONS
	var allowedDirs := [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT, Vector2i.RIGHT]
	allowedDirs.append_array([ Vector2i(1,1),Vector2i(-1,-1),Vector2i(-1,1),Vector2i(1,-1) ] )

	#### GET A LINE OF THE PATH FROM SELF TO TARGET (PLAYER)
	var line: Line2D = world.aStar.createPathBetween(self, movementTarget)
	
	#### DEBUG: SHOW/HIDE LINE
	line.hide()
	
	if line.points.size() < 1:
		push_error("WHAT THE-- PATHING ERROR")
	
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
			
	
	else:
		push_error("WHAT THE SHIT ASTARGRID")
				
	#line.queue_free()
	


func passTurn():
	
	#### TICK COOLDOWNS ETC ON-TURN EFFECTS ON SKILL NODES
	for skill in getSkills():
		skill.passTurn()
	
	#### PLAYER PASSES TURN AFTER TAKING ACTION, SO DO NOTHING NOW
	if isPlayer:
		world.passTurn()
		return
		
	
	#### DON'T DO ANYTHING IF DEAD
	if $HealthComponent.health <= 0:
		return
	
	#### PICK TARGET
	#chooseTarget()
	#### TRY TO USE A SKILL
	if useSkills():
		return
		
	#### TRY TO MOVE	
	creatureMove()	
	


func chooseTarget():
	target = player


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
	
	$HealthComponent.takeDamage(amount)
	$AnimationComponent.playMeleeHit()


func handlePhysicalHit(damage:int):
	$Stats.handlePhysicalHit(damage)


func recoverHealth(amount: int):
	$HealthComponent.recoverHealth(amount)
	#$AnimationComponent.playMeleeHit()


func hasFullHealth():
	var he := $HealthComponent
	return he.health >= he.maxHealth	


func playMovementWobble():
	$SpriteAnimations.play("MovementWobble")
	
	
func getNavigator():
	return $NavigationAgent2D
	

func getSkills():
	return get_node("Skills").get_children()


func getHealth():
	return $HealthComponent.health


func _on_mouse_area_mouse_entered() -> void:
	
	if world.isOverworld:
		return
	
	prints("Mouse entered: ", creatureName)
	world.ui.showMouseLookCreature(self)
