extends NavigationRegion2D


@export var isOverworld := false



@export var dungeonName := "Cool Dungeon Name"

@export var roomSize := 16


@export var turnOffLineOfSight := false
@export var debugImmortalPlayer := false
@export var debugShowVoidTiles := false


var game:Node = null
var currentRoom: Node = null

var exitGridPos := Vector2i.ZERO
var startingGridPos := Vector2i.ZERO

var firstRoom:Node = null
var lastRoom:Node = null

var pathTiles := []
var pathTurns := []


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

@onready var player:Player = null
		

@onready var lookTool := $Utilities/LookTool

var turnActorsList := {}
var turnActorCounter := 0
var isTurnActorPlayer


#var isFirstTurn := false
var isMapKilled := true



func startGame(game:Node, playerScene:Node):

	#### SETUP SELF AND UI
	self.game = game
	ui.toggleLoadingScreen(true)
	States.inputModeOff()
	var pointlessReturn = null
	
	
	if debugShowVoidTiles:
		$Utilities/VoidTiles.show()
	else:
		$Utilities/VoidTiles.hide()
	
	
	#### SETUP PLAYER
	player = playerScene
	$Creatures.add_child(player)
	#prints("player at start of game: ", player, player.creatureName)
	player.playerSetup(self, false)
	
	ui.setup(self)
	ui.displayPlayerSkills(player)
	ui.updateVisualsOnTurn()
	
	#####################################################
	#### ROOMS STUFF
	#### SETUP ASTARGRID TO CREATE PATH BETWEEN ROOM SCENES
	pointlessReturn = $AStarGridNode.setup(self)
	set_navigation_layer_value(2, true)
	
	pointlessReturn = generateDungeon()
	
	#### PLACE THE PLAYER ON THE MAP
	#### ROOMS[0]: FIRST ROOM PLACED
	startingGridPos = firstRoom.getStartPosition()
	player.gridPosition = startingGridPos
	grid.placeGridObjectOnMap(player, startingGridPos)
	
	#### PLACE EXIT - SAVED DURING ROOMS DICT CREATION
	exitGridPos = lastRoom.getStartPosition()
	grid.placeGridObjectOnMap($ExitSprite, exitGridPos)
	
	#### PLACE BOSS
	var boss = FileLoader.createRandomBoss()
	addCreature(boss)
	var lastRoomSpawnPos = lastRoom.getPlayerStartPos()
	boss.gridPosition = lastRoomSpawnPos
	grid.placeGridObjectOnMap(boss, lastRoomSpawnPos)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	#### CREATE VOID TILES, ETC
	pointlessReturn = $GridController.setup(self)
	##########################################
	#### NAV STUFF
	#### SETUP, NOTHING TO WAIT
	pointlessReturn = $LineOfSight.setup(self)
	
	
	
	######################################################
	#### ADD CREATURES TO SPAWN LOCATIONS
	#### CREATURES ARE SETUP IN PopulateCreatures()
	var creatures: Array = []
	for room in getRooms():
		creatures.append_array(room.populateCreatures(self) )
	for creature in creatures:
		$Creatures.add_child(creature)
	
	
	#### SHROUD THE WHOLE MAP IN FOG PRE- LINE OF SIGHT CHECKS
	if not turnOffLineOfSight:
		for x in range(-200,200):
			for y in range(-200,200):
				$Utilities/FogTiles.set_cell(Vector2i(x,y), 0, Vector2i(0,0))
	
	
	
	$Utilities/DumbTimer.start()
	
	#### INPUT MANAGEMENT
	isMapKilled = false
	
	
	
func generateDungeon():
	
	#### TRYING NEW PATH STUFF
	var walkerRoomPositions = $RoomGeneration/Walker2.walk(100,grid)
	pathTurns = walkerRoomPositions
	
	
	pathTiles = generatePath(walkerRoomPositions) 
	for coord in pathTiles:
		$RoomGeneration/GlobalFloorTiles.set_cell(coord, 6, Vector2i.ZERO)
	
	
	#### TRY TO CREATE ROOMS ALONG PATH
	var count := 0
	var occupiedTiles := []
	var latest:Node = null
	
	for tile in pathTurns:
		prints("pathtiles worldgen: ", tile)
		var suitableLocation = true
					
		if suitableLocation:
			var scene = FileLoader.createRandomRoom()
			placeRoom(scene, tile - Vector2i(25,25))
			occupiedTiles.append(tile)
			if count == 0:
				firstRoom = scene
			count += 1
			latest = scene
	
	lastRoom = latest
			
	#### OPEN UP HOLES IN ROOM WALLS SO THE PATH CAN BE TRAVELED
	#### GRAPHICS: 0 castle, 1 forest, 2 desert
	var graphicsValue = randi_range(0,2)
	for room in getRooms():
		room.createOpenPathFromArray(pathTiles)
		room.setTileGraphics(graphicsValue)
		
	return pathTiles


#### GENERATE A PATH BETWEEN ROOMS
#### INPUT: ARRAY OF COORDS. WAYPOINTS TO CREATE PATHS BETWEEN
func generatePath(dungeonPath:Array) -> Array:
	
	var allPathTiles := []
	
	#### CREATE ASTAR PATHS BETWEEN EACH OF THEM
	var paths := []
	for i in range(1, dungeonPath.size()):
		paths.append(aStar.createPathManhattan(dungeonPath[i-1], dungeonPath[i]))
	
	#### CONVERT THEM TO GRID COORDINATES
	var gridPaths := []	
	for path in paths:
		var gridPath := []
		for coord in path:
			#### CONVERSION FROM REGULAR COORDINATES
			var converted = coord / 32 - Vector2(16.5, 16.5)
			if not converted in allPathTiles:
				gridPath.append(converted)
				allPathTiles.append(Vector2i(converted))
		gridPaths.append(gridPath)
	
		
	prints("Path by aStar node: ", allPathTiles )
	return allPathTiles
	

func placeRoom(roomScene:Node, gridPos:Vector2i):
	
	$Rooms.add_child(roomScene) 
	roomScene.placeOnGrid(gridPos)
	roomScene.setup(self)	
	
			
#### SETUP EACH ROOM HERE - ALSO CALL ITS SETUP FUNCTION
#### AND ROOM'S PLACEMENT AND SPRITE GRAPHICS FUNCTIONS
#### ROOMSCENE COMES FROM ROOM LOADER NODE
func instantiateRoom(roomScene:Node, metaCoords:Vector2i):
	
	#var newRoom = roomScene.instantiate()
	var newRoom = roomScene
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
		lookTool.gridPosition = player.gridPosition
		ui.showLookInfo(self, lookTool)
		if isLook:
			grid.placeGridObjectOnMap(lookTool, player.gridPosition)
		#getUi().updateStateLabel(isLook)
		
	
	#### FOR DEBUG
	if Input.is_action_just_pressed("u"):
		for r in getRooms():
			r.randomizeTileGraphics()
	
	#### FOR DEBUG TELEPORTING
	if Input.is_action_just_pressed("X"):
		var lookPos = lookTool.gridPosition
		player.gridPosition = lookPos
		grid.placeGridObjectOnMap(player, lookPos)
		
	
	if Input.is_action_just_pressed("R"):
		$Utilities/Targeting.shuffleTargets()
	
			
	if States.GameState == States.InputStates.LOOK:
		processLook()
		


func startNextTurn():
	
	turnActorCounter = 0
	turnActorsList = {}
	ui.addMessage("A turn passes…", Color.WHITE)
	
	for c in getCreatures(): 
		turnActorsList[turnActorCounter] = c 
		turnActorCounter += 1
	
	#assert(turnActorsList.size() > 0, "WHY NO CREATURES")
	turnActorCounter = -1
	#updateVisuals()
	callNextTurnAction()
	
	
	
func callNextTurnAction():
	
	turnActorCounter += 1
	if turnActorCounter > turnActorsList.size() - 1:
		startNextTurn()
		return
	
		
	var next = turnActorsList[turnActorCounter]
	
	#### CREATURE THAT JUST DIED
	if not is_instance_valid(next):
		prints("Creature can't start turn due to death! (%d)" % [turnActorCounter])
		callNextTurnAction()
		return
	elif next.is_queued_for_deletion():
		prints("%s can't start turn due to death! (%d)" % [next.creatureName, turnActorCounter])
		callNextTurnAction()
		return	
	#### CREATURE IS ALIVE	
	else:
		prints("%s :s turn! (%d)" % [next.creatureName, turnActorCounter])
		next.startTurn()
			
	
	#### UPDATE VISUALS ONLY AFTER PLAYER ACTION
	#### ONLY IF NEXT CREATURE IS ALIVE
	if next.isPlayer:
		isTurnActorPlayer = true
		#lineOfSight.passTurn()
	elif isTurnActorPlayer:
		print("This message plays after player turn")
		updateVisuals()
		isTurnActorPlayer = false

	

func updateVisuals():
	ui.updateVisualsOnTurn()
	$AStarGridNode.passTurn()
	#### REMOVE TARGETING LINES FROM SCREEN
	lineOfSight.passTurn()
	
	if not turnOffLineOfSight:
		lineOfSightStuff()
		
	#### CREATE LIST OF CURRENT TARGETS
	if not is_instance_valid(player):
		return
		
	$Utilities/Targeting.createTargetingDict()
	$Utilities/Targeting.autoSetTarget()

	
	
#### FOG OF WAR STUFF??
func lineOfSightStuff():	
	
	var playerPos: Vector2i = player.gridPosition
	var coordsToCheck:Array = grid.getCoordsInRange(playerPos, 15)	
	$LineOfSight.lineOfSightInRange(playerPos, coordsToCheck, $Utilities/FogTiles)
	
	

#func createPathBetween(creature, target):
	#return $AStarGridNode.pathStuff(creature, target)


func processLook():
	$Utilities/LookTool.processLook(self)


func addCreature(creature:Node):
	creature.basicSetup(self)
	$Creatures.add_child(creature)
	


#### ORDER GAME TO GENERATE NEW DUNGEON LEVEL
func resetLevel():
	isMapKilled = true
	game.storedPlayer = player
	$Creatures.remove_child(player)
	game.generateNewLevel(player)
	self.queue_free()


###################################################################


	
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
	var pointlessReturn = $AStarGridNode.setupGrid()
	bake_navigation_polygon(true)
	
	
		

func _on_bake_finished() -> void:
	
	await get_tree().process_frame
	States.inputModeExplore()
	ui.toggleLoadingScreen(false)
	
	if not turnOffLineOfSight:
		lineOfSightStuff()
	
	#### CREATE LIST OF CURRENT TARGETS
	$Utilities/Targeting.setup(self)
	$Utilities/Targeting.createTargetingDict()
	$Utilities/Targeting.autoSetTarget()
	
	startNextTurn()
