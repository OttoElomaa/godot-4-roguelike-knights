extends NavigationRegion2D


@export var isOverworld := false

@export var turnOffLineOfSight := false

var game:Node = null
var currentRoom: Node = null

@onready var grid:Node:
	get:
		return $GridController
		
var lineOfSight:
	get:
		return $LineOfSight

var aStar:
	get:
		return $AStarGridNode

var ui:
	get:
		return $UI

var voidTilemap:
	get:
		return $Utilities/VoidTiles

@onready var player:
	get:
		return $Creatures/Player
		

@onready var lookTool := $Utilities/LookTool

var isFirstTurn := false
#var FirstRoom := load("res://Scenes/BaseRoom.tscn")
#var SecondRoom := load("res://Rooms/Basic/EntranceWest/BasicWestEast01.tscn")
#var TestRoom := load("res://Rooms/Basic/EntranceWest/TestRoom01.tscn")




func startGame(game):

	self.game = game
	
	States.inputModeOff()
	var pointlessReturn = null
	
	#var roomScenes:Dictionary = $RoomGeneration.generateRooms(self)
	var roomScenes:Dictionary = $RoomGeneration.generateRoomsVersionTwo(self)
	#await get_tree().process_frame
	#await get_tree().process_frame
	
	player.playerSetup(self, false)
	getUi().displayPlayerSkills(getPlayer())
	
	#####################################################
	#### ROOMS STUFF
	#### SETUP ASTARGRID TO CREATE PATH BETWEEN ROOM SCENES
	pointlessReturn = $AStarGridNode.setup(self)
	set_navigation_layer_value(2, true)
	
	await get_tree().process_frame
	await get_tree().process_frame
	pointlessReturn = generateDungeon(roomScenes)
	
	#### PLACE THE PLAYER ON THE MAP
	#### ROOMS[0]: FIRST ROOM PLACED
	var startingRoom = getRooms()[0]
	startingRoom.startGameAtRoom(getPlayer())
	
	await get_tree().process_frame
	await get_tree().process_frame
	pointlessReturn = $GridController.setup(self)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	
	
	$Utilities/DumbTimer.start()
	#for room in getRooms():
		#prints("room position: ",room.position)
	
	
	######################################################
	#### ADD CREATURES TO SPAWN LOCATIONS
	#### CREATURES ARE SETUP IN PopulateCreatures()
	var creatures: Array = []
	for room in getRooms():
		creatures.append_array(room.populateCreatures() )
	for creature in creatures:
		$Creatures.add_child(creature)
	
	##########################################
	#### NAV STUFF
	#### SETUP, NOTHING TO WAIT
	pointlessReturn = $LineOfSight.setup(self)
	
	if not turnOffLineOfSight:
		for x in range(-200,200):
			for y in range(-200,200):
				$Utilities/FogTiles.set_cell(Vector2i(x,y), 0, Vector2i(0,0))
	
	#### LINE OF SIGHT SETUP
	
	
	
	
	

func generateDungeon(roomScenes:Dictionary):
	
	for coord in roomScenes.keys():
		var scene = roomScenes[coord]
		instantiateRoom(scene, coord)	
	
	return generatePath() #### GENERATE A PATH BETWEEN ROOMS



#### GENERATE A PATH BETWEEN ROOMS	
func generatePath():
	
	#### MAKE A SET OF POINTS THAT NEED TO CONNECT
	var dungeonPath := []
	for room in getRooms():	
		dungeonPath.append(room.getStartPosition())
	
	#### CREATE ASTAR PATHS BETWEEN EACH OF THEM
	var paths := []
	for i in range(1, dungeonPath.size()):
		paths.append(aStar.createPathManhattan(dungeonPath[i-1], dungeonPath[i]))
		#prints("start: ", dungeonPath[i-1]," end: ",dungeonPath[i])
	
	#### CONVERT THEM TO GRID COORDINATES
	var gridPaths := []	
	for path in paths:
		var gridPath := []
		for coord in path:
			#### CONVERSION FROM REGULAR COORDINATES
			gridPath.append(coord / 32 - Vector2(16.5, 16.5))
		gridPaths.append(gridPath)
	
		
	#### CREATE THE 1-WIDE PATH BETWEEN ROOMS
	for room in getRooms():
		room.generateOpenPath(gridPaths)
		room.randomizeTileGraphics()	
		
	return
	#for path in paths:
		#prints("path: ", path)
	#for path in gridPaths:
		#prints("path: ", path)
		
		
	#instantiateRoom(FirstRoom, Vector2.ZERO)
	#instantiateRoom(TestRoom, Vector2i.RIGHT)
		

#### SETUP EACH ROOM HERE - ALSO CALL ITS SETUP FUNCTION
#### AND ROOM'S PLACEMENT AND SPRITE GRAPHICS FUNCTIONS
#### ROOMSCENE COMES FROM ROOM LOADER NODE
func instantiateRoom(roomScene:PackedScene, metaCoords:Vector2i):
	
	var newRoom = roomScene.instantiate()
	$Rooms.add_child(newRoom) 
	newRoom.setup(self)	
	
	#### MOVE ROOM INTO POSITION BASED ON META POSITION AND GLOBAL ROOM SIZE
	newRoom.placeOnMetaGrid(metaCoords) 
	
	#newRoom.randomizeTileGraphics()
	#prints("init success! ", newRoom.position)


func _process(delta: float) -> void:
	
	
	if Input.is_action_just_pressed("O"):
		for node in $Disposables.get_children():
			node.queue_free()
	
	if Input.is_action_just_pressed("L"):
		
		#### ACTUAL LOOK STUFF
		var isLook = States.handleLook()
		lookTool.gridPosition = getPlayer().gridPosition
	
		getUi().updateStateLabel(isLook)
		
	
	if Input.is_action_just_pressed("u"):
		for r in getRooms():
			r.randomizeTileGraphics()
			
	if States.GameState == States.InputStates.LOOK:
		processLook()
		


func passTurn():
	
	$AStarGridNode.passTurn()
	lineOfSight.passTurn()
	
	#bake_navigation_polygon(true)
	
	
	for creature in getCreatures():
		if creature != getPlayer():
			creature.passTurn()
	
	if not turnOffLineOfSight:
		lineOfSightStuff()
	
	if isFirstTurn:
		#bake_navigation_polygon(true)
		isFirstTurn = false
	
	
#### FOG OF WAR STUFF??
func lineOfSightStuff():	
	
	var playerPos: Vector2i = getPlayer().gridPosition
	var coordsToCheck:Array = grid.getCoordsInRange(playerPos, 15)	
	$LineOfSight.lineOfSightInRange(playerPos, coordsToCheck, $Utilities/FogTiles)
	
	

#func createPathBetween(creature, target):
	#return $AStarGridNode.pathStuff(creature, target)


func processLook():
	$Utilities/LookTool.processLook(self)



	

func getPlayer():
	return $Creatures/Player
	
func getGrid():
	return $GridController

func getAStar():
	return $AStarGridNode
		
func getRooms():
	return $Rooms.get_children()

func getCreatures():
	return $Creatures.get_children()


func getAllies():
	
	var returnCreatures := []
	for c in getCreatures():
		
		if not c.isEnemy:
			returnCreatures.append(c)
	return returnCreatures
	

func getEnemies():
	
	var returnCreatures := []
	for c in getCreatures():
		
		if c.isEnemy:
			returnCreatures.append(c)
	return returnCreatures
	
	
	
func getUi():
	return $UI


func _on_dumb_timer_timeout() -> void:
	bake_navigation_polygon(true)
	var pointlessReturn = $AStarGridNode.setupGrid()
	
		

func _on_bake_finished() -> void:
	
	await get_tree().process_frame
	States.inputModeExplore()
	ui.closeLoadingScreen()
	
	if not turnOffLineOfSight:
		lineOfSightStuff()
