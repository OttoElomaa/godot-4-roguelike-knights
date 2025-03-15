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


@onready var grid := $GridController
@onready var lineOfSight := $LineOfSight
@onready var aStar := $AStarGridNode
@onready var ui := $UI

@onready var voidTilemap := $Utilities/VoidTiles

@onready var player:Player = null
		

@onready var lookTool := $Utilities/LookTool

var turnActorsList := {}
var turnActorCounter := 0
var isTurnActorPlayer


#var isFirstTurn := false
var isMapKilled := true



func startGame(game:Node, playerScene:Node, dungeonInfo:Object):

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
	
	#prints("player at start of game: ", player, player.creatureName)
	
	$Utilities/LookTool.setup(self)
	
	
	
	#####################################################
	#### ROOMS STUFF
	#### SETUP ASTARGRID TO CREATE PATH BETWEEN ROOM SCENES
	pointlessReturn = $AStarGridNode.setup(self)
	$GridController.setup(self)
	set_navigation_layer_value(2, true)
	
	pointlessReturn = generateDungeon()
	
	#### PLACE THE PLAYER ON THE MAP
	#### ROOMS[0]: FIRST ROOM PLACED
	startingGridPos = firstRoom.getStartPosition()
	
	addCreature(player)
	grid.putOnGridAndMap(player, startingGridPos)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	ui.setup(self)
	ui.displayPlayerSkills(player)
	ui.updateVisualsOnTurn()
	
	#### PLACE EXIT - SAVED DURING ROOMS DICT CREATION
	exitGridPos = lastRoom.getStartPosition()
	grid.placeGridObjectOnMap($ExitSprite, exitGridPos)
	
	#### PLACE BOSS
	var boss = FileLoader.createRandomBoss()
	addCreature(boss)
	var lastRoomSpawnPos = lastRoom.getPlayerStartPos()
	grid.putOnGridAndMap(boss, lastRoomSpawnPos)
	
	
	
	#### CREATE VOID TILES, ETC
	pointlessReturn = $GridController.setupGrid()
	#### LOS STUFF SETUP, NOTHING TO WAIT
	pointlessReturn = $LineOfSight.setup(self)
	
	
	######################################################
	
	var creatures: Array = []
	#### ADD CREATURES TO SPAWN LOCATIONS IN EACH ROOM
	for room in getRooms():
		if not room == firstRoom:  ## SKIP FIRST ROOM
			#### CREATURES ARE SETUP IN PopulateCreatures()
			creatures.append_array(room.populateCreatures(self) )
		
	for creature in creatures:
		addCreature(creature)
		grid.putOnGridAndMap(creature, creature.gridPosition)
	
	
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
	var walkerRoomPositions = $RoomGeneration/Walker2.walk(20)
	pathTurns = walkerRoomPositions
	
	
	generatePath(walkerRoomPositions) 
	pathTiles = $RoomGeneration/GlobalFloorTiles.get_used_cells()
	
	
	#### TRY TO CREATE ROOMS ALONG PATH
	var count := 0
	var latest:Node = null
	
	for point in pathTurns:
		prints("pathtiles worldgen: ", point.gridPosition)
					
		if point.hasRoom:
			var scene = FileLoader.createRandomRoom()
			placeRoom(scene, point.gridPosition - Vector2i(25,25))
			if count == 0:
				firstRoom = scene
			count += 1
			latest = scene
	
	lastRoom = latest
			
	#### OPEN UP HOLES IN ROOM WALLS SO THE PATH CAN BE TRAVELED
	for room in getRooms():
		room.createOpenPathFromArray(pathTiles)
		randomizeLevelTileGraphics()
		
	return pathTiles


#### GENERATE A PATH BETWEEN ROOMS
#### INPUT: ARRAY OF COORDS. WAYPOINTS TO CREATE PATHS BETWEEN
func generatePath(dungeonPath:Array) -> Array:
	
	var allPathTiles := []
	
	#### CREATE ASTAR PATHS BETWEEN EACH OF THEM
	var paths := []
	for i in range(1, dungeonPath.size()):
		var prev = dungeonPath[i-1].gridPosition
		var curr = dungeonPath[i].gridPosition
		paths.append(aStar.createPathManhattan(prev, curr))
	
	#### CONVERT THEM TO GRID COORDINATES
	for path in paths:
		for coord in path:
			#### CONVERSION FROM REGULAR COORDINATES
			var converted = coord / 32 - Vector2(16.5, 16.5)
			$RoomGeneration/GlobalFloorTiles.set_cell(converted, 6, Vector2i.ZERO)
			
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
	
	#### FOR DEBUG
	if Input.is_action_just_pressed("u"):
		randomizeLevelTileGraphics()
	
	#### FOR DEBUG TELEPORTING
	if Input.is_action_just_pressed("X"):
		var lookPos = lookTool.gridPosition
		player.gridPosition = lookPos
		grid.placeGridObjectOnMap(player, lookPos)
		
	
	if Input.is_action_just_pressed("R"):
		$Utilities/Targeting.shuffleTargets()
	
	
	#### DEBUG CREATE NEW LEVEL	
	if Input.is_action_just_pressed("B"):
		resetLevel()
		


func startNextTurn():
	
	turnActorCounter = 0
	turnActorsList = {}
	ui.addMessage("A turn passes…", MyColors.fontFaintBrown)
	
	for c in getCreatures(): 
		turnActorsList[turnActorCounter] = c 
		turnActorCounter += 1
	
	#assert(turnActorsList.size() > 0, "WHY NO CREATURES")
	turnActorCounter = -1
	#updateVisuals()
	callNextTurnAction(null)
	
	
	
func callNextTurnAction(previous:Node):
	
	turnActorCounter += 1
	if turnActorCounter > turnActorsList.size() - 1:
		startNextTurn()
		return
	
		
	var next = turnActorsList[turnActorCounter]
	
	#### CREATURE THAT JUST DIED
	if not is_instance_valid(next):
		prints("Creature can't start turn due to death! (%d)" % [turnActorCounter])
		callNextTurnAction(null)
		return
	elif next.is_queued_for_deletion():
		prints("%s can't start turn due to death! (%d)" % [next.creatureName, turnActorCounter])
		callNextTurnAction(null)
		return	
		
	#### CREATURE IS ALIVE	
	
	prints("%s :s turn! (%d)" % [next.creatureName, turnActorCounter])
	
	#### UPDATE VISUALS ONLY AFTER PLAYER ACTION
	#### ONLY IF NEXT CREATURE IS ALIVE
	if next.isPlayer:
		#### WAIT 0.1 sec, so LINE OF SIGHT CHECKS HAVE COMPLETED. THEN TARGETING STUFF
		handleFogOfWar()
		$LineOfSight/FogOfWarTimer.start()
	
	#### AFTER PLAYER ACTION	
	if previous != null:
		if previous.isPlayer:
			print("This message plays after player turn")
			lineOfSight.passTurn()  #### Deletes Visual Ranged Shoot Lines
		
	next.startTurn()
			
	
	
	


func updateVisuals():
	ui.updateVisualsOnTurn()
	$AStarGridNode.passTurn()
	#### REMOVE TARGETING LINES FROM SCREEN		
	#updateTargeting()



func updateTargeting():		
	#### CREATE LIST OF CURRENT TARGETS
	if not is_instance_valid(player):
		return
		
	$Utilities/Targeting.createTargetingDict()
	$Utilities/Targeting.autoSetTarget()
	ui.showTargetCreature(player.selectedTarget)
	
	
#### FOG OF WAR STUFF??
func handleFogOfWar():
	
	if turnOffLineOfSight:
		return
	if not player:
		return	
	if not player.checkValidity():
		return
		
	var playerPos: Vector2i = player.gridPosition
	var seeRange := 8
	$LineOfSight.handleFogOfWar(playerPos, seeRange, $Utilities/FogTiles)
	


func putOnGridAndMap(player:Node, startingGridPos:Vector2i) -> bool:
	return grid.putOnGridAndMap(player, startingGridPos)


func addCreature(creature:Node):
	
	if creature.isPlayer:
		player.playerSetup(self, false)
	else:
		creature.setup(self)
	
	#if grid.is_tile_empty()
		
	$Creatures.add_child(creature)
	
	

#### ORDER GAME TO GENERATE NEW DUNGEON LEVEL
func resetLevel():
	isMapKilled = true
	game.storedPlayer = player
	$Creatures.remove_child(player)
	game.generateNewLevel(player)
	self.queue_free()


#### RANDOMIZE A GRAPHICS VALUE (It's a TILE ATLAS OFFSET)
#### 0 = CASTLE  |  1 = FOREST  |  2 = DESERT
func randomizeLevelTileGraphics():
	
	var graphicsValue = randi_range(0,2)
	for room in getRooms():
		room.setTileGraphics(graphicsValue)


############################################################
#### BOONS

#### CALLED FROM CreatureMovement.HandleMove
#### VIA WORLD SCENE -> To All Creatures
func triggerBoonAdjacentStep(creature:Node):
	for c in getCreatures():
		if not c == creature:
			c.triggerBoonAdjacentStep(creature)


###################################################################
		
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
	
	

func _on_dumb_timer_timeout() -> void:
		
	var rect = voidTilemap.get_used_rect()
	rect.position *= 32
	rect.size *= 32
	prints("rect: ", rect)  
	navigation_polygon.baking_rect = rect
	
	var pointlessReturn = $AStarGridNode.setupGrid()
	bake_navigation_polygon(true)
	
	
		

func _on_bake_finished() -> void:
	
	await get_tree().process_frame
	
	#### SOMETIMES THE NAVMESH BAKING FAILS
	if navigation_polygon.get_vertices().size() <= 0:
		print("Retrying navmesh bake")
		#bake_navigation_polygon(true)
		resetLevel()
		return
	
	#assert(navigation_polygon.get_vertices().size() > 0, "Bake failed??")
	
	States.inputModeExplore()
	ui.toggleLoadingScreen(false)
	
	
	handleFogOfWar()
	
	#### CREATE LIST OF CURRENT TARGETS
	$Utilities/Targeting.setup(self)
	$Utilities/Targeting.createTargetingDict()
	$Utilities/Targeting.autoSetTarget()
	
	startNextTurn()


	
#### AFTER PLAYER TURN, DO VISUAL STUFF	
func _on_fog_of_war_timer_timeout() -> void:
	
	#if not turnOffLineOfSight:
		#handleFogOfWar()
	updateTargeting()
