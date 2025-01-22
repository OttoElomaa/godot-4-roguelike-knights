class_name Player
extends Creature



#var isOverworld := false
var isZoomedIn := true




func playerSetup(world, isThisOverworld):
	self.world = world
	grid = world.grid
	$MovementInput.setup(self)
	
	isOverworld = isThisOverworld
	
	#### TESTING SETUP STUFF
	gridPosition = world.grid.world_to_grid(self.position)
	position = world.grid.grid_to_world(gridPosition)
	
	
	$CreatureMovement.setup(self)
		
	if isOverworld:
		return
	
	$HealthComponent.setup(self)
	$Stats.setup(self)
	
	$AnimationComponent.setup(self)
	$CreatureMovement.setup(self)
	
	for skill in $Skills.get_children():
		skill.setup(self)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if States.GameState == States.InputStates.EXPLORE:
		self.processExplore()
	
	

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
	#if skillToUse in [1,2]:
		#creatures = grid.getAdjacentCreatures(self)
		
		#### NO MELEE ENEMIES
		#if creatures.is_empty():
			#print("No melee creatures!")
			#return
	
		#### MELEE ENEMY/IES FOUND
		#for cre in creatures:
			#print(cre.creatureName)
	
	match skillToUse:
		#### USE SKILL	
		1:
			self.useSkill(0)
			
		2:
			self.useSkill(1)
		

	
func useSkill(index):
	
	var skill = self.getSkills()[index]
	skill.activate()
	passTurn()



#func getSkills():
	##var skillsNode = self.get_node("Skills")
	#var skillsNode = self.get_node("Skills")
	#for c in self.get_children():
		#print(c)
	#return skillsNode.get_children()



func getNavigator():
	return $LineOfSightNavigator
