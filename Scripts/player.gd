extends Node2D

var world: Node = null
var grid: Node = null

var gridPosition := Vector2i.ZERO

var isEnemy := false
@export var isOverworld := false

@export var creatureName := ""


var isZoomedIn := true



func setup(world, isThisOverworld):
	self.world = world
	grid = world.grid
	$Movement.setup(self)
	
	#### TESTING SETUP STUFF
	gridPosition = world.grid.world_to_grid(self.position)
	position = world.grid.grid_to_world(gridPosition)
	
	isOverworld = isThisOverworld
	$Movement.isOverworld = isOverworld
	if isOverworld:
		return
	$Movement.dungeonSetup()
		
	$HealthComponent.setup(self)
	for skill in $Skills.get_children():
		skill.setup(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if States.GameState == States.InputStates.EXPLORE:
		processExplore()
	
	

func processExplore():
	
	var skillToUse := 0
	var creatures := []
	
	if Input.is_action_just_pressed("1"):
		skillToUse = 1
	elif Input.is_action_just_pressed("2"):
		skillToUse = 2
	
	elif Input.is_action_just_pressed("Z"):
		if isZoomedIn:
			$Camera2D.zoom = Vector2(0.4, 0.4)
			isZoomedIn = false
		else:
			$Camera2D.zoom = Vector2(2, 2)
			isZoomedIn = true
	
	
	
	#### NO SKILL PICKED	
	if skillToUse == 0:
		return
	
	#### A SKILL WAS PICKED
	if skillToUse in [1,2]:
		creatures = grid.getAdjacentCreatures(self)
		
		#### NO MELEE ENEMIES
		if creatures.is_empty():
			print("No melee creatures!")
			return
	
		#### MELEE ENEMY/IES FOUND
		for cre in creatures:
			print(cre.creatureName)
	
	match skillToUse:
		#### USE SKILL	
		1:
			useSkill(0, creatures[0])
			
		2:
			useSkill(1, creatures[0])
		
	
			
func passTurn():
	#if not isOverworld:
	world.passTurn()
	#$AnimationComponent.reset()


func useSkill(index, target):
	
	$Skills.get_children()[index].activate(target)
	passTurn()



func takeDamage(amount: int):
	$HealthComponent.takeDamage(amount)
	$AnimationComponent.playMeleeHit()

	
func getSkills():
	return $Skills.get_children()
	

func getHealth():
	return $HealthComponent.health
	
	




func getNavigator():
	return $LineOfSightNavigator



func playMovementWobble():
	$SpriteAnimations.play("MovementWobble")
