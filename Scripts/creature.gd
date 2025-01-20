extends Node2D



var world:Node = null
var grid:Node = null
var aStarGrid:AStarGrid2D = null
var player:Node = null

var gridPosition := Vector2i.ZERO
var target:Node = null

var isEnemy := true

@export var creatureName := ""	
	

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
	
	
	
	
	
func pathStuff():

	#### CREATURE CAN MOVE IN THESE DIRECTIONS
	var allowedDirs := [Vector2.UP,Vector2.DOWN,Vector2.LEFT, Vector2.RIGHT]
	allowedDirs.append_array([ Vector2(1,1),Vector2(-1,-1),Vector2(-1,1),Vector2(1,-1) ] )

	#### GET A LINE OF THE PATH FROM SELF TO TARGET (PLAYER)
	var line: Line2D = world.pathStuff(self, world.getPlayer())
	line.hide()
	
	#### IF ADJACENT TO TARGET, DON'T MOVE
	if line.points.size() < 3:
		return
	
	#### COMPARE TARGET POSITION TO CREATURE POSITIONS
	var dir = position.direction_to(line.points[1])
	dir = Vector2(round(dir.x), round(dir.y))
	
	print(dir)
	var creaturePositions : Array = grid.getCreatureTiles()
	
	if dir in allowedDirs:
		var targetGridPos = gridPosition + Vector2i(dir)
		
		#### IF TARGET POSITION IS OCCUPIED BY CREATURE, DON'T MOVE
		if targetGridPos in creaturePositions:
			return
		else:
			move(dir)
				
	#line.queue_free()
	


func passTurn():
	
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
	
	var tiles = get_tree().get_first_node_in_group("tilecontroller")
	
	gridPosition += Vector2i(vector)
	tiles.placeGridObjectOnMap(self, gridPosition)
	

func takeDamage(amount:int):
	
	$HealthComponent.takeDamage(amount)
	$AnimationComponent.playMeleeHit()
	
	
func getNavigator():
	return $NavigationAgent2D
