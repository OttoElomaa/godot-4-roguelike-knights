class_name Player
extends Creature



#var isOverworld := false
var isZoomedIn := true
var zoomLevel := 0

var selectedTarget:Node = null



func playerSetup(world, isThisOverworld):
	
	$MovementInput.setup(self)
	isOverworld = isThisOverworld
	
	#### TESTING SETUP STUFF
	gridPosition = GridTools.localToGrid(self.position)
	position = GridTools.gridToWorld(gridPosition)
	
	if isOverworld:
		return
		
	#### CALLS THE CREATURE SETUP FUNC
	self.call("setup", world)
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not world:
		return
	elif world.isMapKilled:
		return
	
	if States.GameState == States.InputStates.EXPLORE:
		self.processExplore()
	
	

func processExplore():
	
	var skillToUse := 0
	var creatures := []
	
	if Input.is_action_just_pressed("1"):
		skillToUse = 1
	elif Input.is_action_just_pressed("2"):
		skillToUse = 2
	elif Input.is_action_just_pressed("3"):
		skillToUse = 3
	elif Input.is_action_just_pressed("4"):
		skillToUse = 4
	
	elif Input.is_action_just_pressed("Z"):
		
		match zoomLevel:
			0:
				$Camera2D.zoom = Vector2(0.4, 0.4)
				zoomLevel = 1
			1:
				$Camera2D.zoom = Vector2(0.2, 0.2)
				zoomLevel = 2
			2:
				$Camera2D.zoom = Vector2(2, 2)
				zoomLevel = 0
		
	
	
	
	#### NO SKILL PICKED	
	if skillToUse == 0:
		return
	

	
	match skillToUse:
		#### USE SKILL	
		1,2,3,4:
			self.useSkill(skillToUse-1)
			
	
			
func useSkill(index):
	
	if index > getSkills().size() - 1:
		return
	
	var skill = self.getSkills()[index]
	var success = skill.activate()
	if success:
		finishTurn()
