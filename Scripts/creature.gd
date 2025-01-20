extends Node2D



var world:Node = null
var grid:Node = null
var aStarGrid:AStarGrid2D = null
var player:Node = null

var gridPosition := Vector2i.ZERO
var target:Node = null

var isEnemy := true

@export var creatureName := ""	


#### FOR MOVEMENT ANIMATION
var newPos:Vector2 = Vector2i.ZERO
var t := 0.0
var isMoving := false


func roomSetup(room):
	
	var tree = room.get_tree()
	self.world = tree.root.get_node("GameMain/World")
	self.grid = world.getGrid()
	self.player = world.getPlayer()
	
	$HealthComponent.setup(self)
	$AnimationComponent.setup(self)
	
	for skill in $Skills.get_children():
		skill.setup(self)
	
	
func mySetup():
	pass
	#self.game = game
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("P"):
		pathStuff()
	
	
func _physics_process(delta: float) -> void:
	
	if isMoving:
		
		t += delta * 2.5
		position = position.lerp(newPos, t)
		
		if position == newPos:
			prints("movement goal reached, ", creatureName)
			isMoving = false	
			t = 0.0	
	
	
func pathStuff():

	#### CREATURE CAN MOVE IN THESE DIRECTIONS
	var allowedDirs := [Vector2.UP,Vector2.DOWN,Vector2.LEFT, Vector2.RIGHT]
	allowedDirs.append_array([ Vector2(1,1),Vector2(-1,-1),Vector2(-1,1),Vector2(1,-1) ] )

	#### GET A LINE OF THE PATH FROM SELF TO TARGET (PLAYER)
	var line: Line2D = world.aStar.createPathBetween(self, world.getPlayer())
	
	#### DEBUG: SHOW/HIDE LINE
	#line.hide()
	
	#### IF ADJACENT TO TARGET, DON'T MOVE
	if line.points.size() < 3:
		return
	
	#### COMPARE TARGET POSITION TO CREATURE POSITIONS
	#### ROUND FROM 0.777... TO 1
	var dir = position.direction_to(line.points[1])
	dir = Vector2(round(dir.x), round(dir.y))
	
	#print(dir)
	var creaturePositions : Array = grid.getCreatureTiles()
	
	if dir in allowedDirs:
		var targetGridPos = gridPosition + Vector2i(dir)
		
		#### IF TARGET POSITION IS OCCUPIED BY CREATURE, DON'T MOVE
		if targetGridPos in creaturePositions:
			return
			
		else:
			move(dir)
			line.remove_point(0)
			
	
	else:
		push_error("WHAT THE SHIT ASTARGRID")
				
	#line.queue_free()
	


func passTurn():
	
	if $HealthComponent.health <= 0:
		return
	
	#### PICK TARGET
	chooseTarget()
	#### TRY TO USE A SKILL
	if useSkills():
		return
		
	#### TRY TO MOVE	
	pathStuff()	
	


func chooseTarget():
	target = player


func useSkills() -> bool:
	
	for skill in $Skills.get_children():
		if skill.activate(target) == true:
			return true
	return false


func move(vector):
		
	gridPosition += Vector2i(vector)
	#tiles.placeGridObjectOnMap(self, gridPosition)
	
	newPos = grid.grid_to_world(gridPosition)
	isMoving = true
	$SpriteAnimations.play("MovementWobble")
	
	

func takeDamage(amount:int):
	
	$HealthComponent.takeDamage(amount)
	$AnimationComponent.playMeleeHit()
	
	
func getNavigator():
	return $NavigationAgent2D
