extends Node2D

var world: Node = null
var grid: Node = null

var gridPosition := Vector2i.ZERO

@export var creatureName := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func setup(world):
	self.world = world
	grid = world.getGrid()
	$Movement.setup(self)
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
	world.passTurn()
	
	
	
func getSkills():
	return $Skills.get_children()
	

func getHealth():
	return $HealthComponent.health
	
	

func useSkill(index, target):
	$Skills.get_children()[index].activate(target)


func getNavigator():
	return $NavigationAgent2D
