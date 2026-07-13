extends NavigationRegion2D


@export var isOverworld := false

#@export var dungeonName := "Cool Dungeon Name"


@export var turnOffFogOfWar := false
@export var debugImmortalPlayer := false
@export var debugShowVoidTiles := false


var game:Node = null
var dungeonInfo:Object = null
var dungeonName := "Dungeon Name"

#var currentRoom: Node = null

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
	self.dungeonInfo = dungeonInfo
	dungeonName = dungeonInfo.dungeonName
	
	#### SETUP PLAYER AND INVENTORY
	player = playerScene
	PlayerInventory.setup(self)
	
	#### TURN OFF INPUTS WHILE MAP GENERATES
	ui.toggleLoadingScreen(true)
	States.inputModeOff()
		
	if debugShowVoidTiles:
		$Utilities/VoidTiles.show()
	else:
		$Utilities/VoidTiles.hide()
			
	$Utilities/LookTool.setup(self)
	$Utilities/Targeting.setup(self)
	
	#### SETUP ASTARGRID TO CREATE PATH BETWEEN ROOM SCENES
	await $AStarGridNode.setup(self)
	$GridController.setup(self)
	set_navigation_layer_value(2, true)
	
	
	#####################################################
	#### ROOMS STUFF - GENERATE DUNGEON WITH PREFAB ROOMS
	await generateDungeon()
	
	#### CREATE VOID TILES, ETC
	await $GridController.setupGrid()
	
	addCreature(player)
	
	#### PLACE THE PLAYER ON THE MAP -- ROOMS[0]: FIRST PLACED ROOM
	startingGridPos = firstRoom.getPlayerStartPos()
	grid.putOnGridAndMap(player, startingGridPos)
	
	#await get_tree().process_frame
	#await get_tree().process_frame
	
	ui.setup(self)
	ui.displayPlayerSkills(player)
	ui.updateVisualsOnTurn()
	
	#### PLACE EXIT - SAVED DURING ROOMS DICT CREATION
	exitGridPos = lastRoom.getStartPosition()

	grid.putOnGridAndMap($ExitSprite, exitGridPos)
	
	#### PLACE BOSS
	var boss = FileLoader.createRandomBoss()
	addCreature(boss)
	var lastRoomSpawnPos = lastRoom.getPlayerStartPos()
	grid.putOnGridAndMap(boss, lastRoomSpawnPos)
	
	
	#### LOS STUFF SETUP, NOTHING TO WAIT
	await $LineOfSight.setup(self)
	
	
	######################################################
	#### PLACE CREATURES AND OBJECTS IN EACH ROOM
	
	var creatures: Array = []
	var items: Array = []
	#### ADD CREATURES TO SPAWN LOCATIONS IN EACH ROOM
	for room in getRooms():
		if not room == firstRoom:  ## SKIP FIRST ROOM
			#### CREATURES ARE SETUP IN PopulateCreatures()
			creatures.append_array(room.populateCreatures(self) )
			items.append_array(room.populateRoomItems())
		
	for creature in creatures:
		addCreature(creature)
		grid.putOnGridAndMap(creature, creature.gridPosition)
		
	for obj in items:
		print("placing room object")
		$Objects.add_child(obj)
		obj.setup(self)
		grid.putOnGridAndMap(obj, obj.gridPosition)
		
		
	
	#### SHROUD THE WHOLE MAP IN FOG PRE- LINE OF SIGHT CHECKS
	if not turnOffFogOfWar:
		for x in range(-200,200):
			for y in range(-200,200):
				$Utilities/FogTiles.set_cell(Vector2i(x,y), 0, Vector2i(0,0))
	
	$Utilities/DumbTimer.start()
	#### INPUT MANAGEMENT
	isMapKilled = false
	


func startDebugLevel(game:Node, playerScene:Node, dungeonInfo:Object):
	
	#### SETUP SELF AND UI
	self.game = game
	self.dungeonInfo = dungeonInfo
	dungeonName = dungeonInfo.dungeonName
	player = playerScene
	
	ui.toggleLoadingScreen(true)
	States.inputModeOff()
	
		
	if debugShowVoidTiles:
		$Utilities/VoidTiles.show()
	else:
		$Utilities/VoidTiles.hide()
			
	$Utilities/LookTool.setup(self)
	
	
	#### SETUP ASTARGRID TO CREATE PATH BETWEEN ROOM SCENES
	await $AStarGridNode.setup(self)
	$GridController.setup(self)
	set_navigation_layer_value(2, true)
	
	
	#####################################################
	#### ROOMS STUFF - GENERATE DUNGEON WITH PREFAB ROOMS
	for r in getRooms():
		r.setup(self)
		r.finishRoomSetup()
	
	addCreature(player)
	player.toggleCamera(false)
	
	for c in getCreatures():
		c.setup(self)
		var newPos = GridTools.localToGrid(c.position)
		grid.putOnGridAndMap(c, newPos)
	
	#### PLACE THE PLAYER ON THE MAP -- ROOMS[0]: FIRST PLACED ROOM
	firstRoom = getRooms()[0]
	startingGridPos = firstRoom.getStartPosition()
	grid.putOnGridAndMap(player, startingGridPos)
	
	$Utilities/Targeting.setup(self)
		
	ui.setup(self)
	ui.displayPlayerSkills(player)
	ui.updateVisualsOnTurn()
		
	#### CREATE VOID TILES, ETC
	await $GridController.setupGrid()
	#### LOS STUFF SETUP, NOTHING TO WAIT
	await $LineOfSight.setup(self)
		
	$Utilities/DumbTimer.start()
	#### INPUT MANAGEMENT
	isMapKilled = false


	
func generateDungeon():
	var gen := $RoomGeneration/PathGen3
	var dungeonGenRef:DungeonGenResult = gen.generate()
	
	pathTiles = dungeonGenRef.path_tiles
	#grid.floorTiles.append_array(dungeonGenRef.all_room_floors())
	for tile in dungeonGenRef.all_room_floors():
		grid.setFloor(tile)
	
	#### PAINT THE PATH
	for coord in pathTiles:
		$GridController/GlobalFloorTiles.set_cell(coord, 6, Vector2i.ZERO)
	
	#### TRY TO CREATE ROOMS ALONG PATH
	var count := 0
	var latest:Node = null
	
	for tile in dungeonGenRef.prefab_centers:
		prints("pathtiles worldgen: ", tile)
					
		var scene = FileLoader.createRandomRoom()
		#placeRoom(scene, tile - Vector2i(25,25))
		placeRoom(scene, tile - Vector2i(10,10))
		if count == 0:
			firstRoom = scene
		count += 1
		latest = scene
	
	lastRoom = latest
			
	#### OPEN UP HOLES IN ROOM WALLS SO THE PATH CAN BE TRAVELED
	for room in getRooms():
		room.createOpenPathFromArray(pathTiles)
		setLevelTileGraphics()
		
	return pathTiles



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
	#newRoom.placeOnMetaGrid(metaCoords) 
	
	#newRoom.randomizeTileGraphics()
	#prints("init success! ", newRoom.position)



#### derive WALL tiles from FLOOR tiles. WALL = non-floor neighbor of any floor tile.
#### EDGE WALL = wall with floor BELOW it (+Y on screen); from the floor's view that's its UP (-Y) neighbor.
#### returns { walls, edge_walls, non_edge_walls } as deduped Array[Vector2i].
func wallsFromFloors(floors: Array[Vector2i]) -> Dictionary:
	var wall_set: Dictionary = {}        # coord -> true. THE dedup.
	var edge_set: Dictionary = {}        # coord -> true. edge walls.

	# 8 neighbor offsets. UP (-Y) handled specially for the edge test.
	var offsets: Array[Vector2i] = [
		Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1),
	]

	for f in floors:
		for o in offsets:
			var n := f + o
			if n in floors or n in pathTiles:
				continue                 # neighbor is floor, not a wall
			wall_set[n] = true
			# this wall has floor (f) directly below it -> EDGE wall.
			if o == Vector2i(0, -1):
				edge_set[n] = true

	# split into edge / non-edge from the two sets.
	var walls: Array[Vector2i] = []
	var edge_walls: Array[Vector2i] = []
	var non_edge_walls: Array[Vector2i] = []
	for w in wall_set:
		walls.append(w)
		if edge_set.has(w):
			edge_walls.append(w)
		else:
			non_edge_walls.append(w)

	return { "walls": walls, "edge_walls": edge_walls, "non_edge_walls": non_edge_walls }


#############################################################################
#### GAMEPLAY OPERATIONS

func _process(delta: float) -> void:
	
	
	if Input.is_action_just_pressed("O"):
		for node in $Disposables.get_children():
			node.queue_free()
	
	#### FOR DEBUG
	if Input.is_action_just_pressed("u"):
		setLevelTileGraphics()
	
	#### FOR DEBUG TELEPORTING
	if Input.is_action_just_pressed("X"):
		var lookPos = lookTool.gridPosition
		player.gridPosition = lookPos
		grid.placeGridObjectOnMap(player, lookPos)
		
	
	if Input.is_action_just_pressed("R"):
		$Utilities/Targeting.shuffleTargets()
	
	
	#### DEBUG CREATE NEW LEVEL	
	if Input.is_action_just_pressed("B"):
		resetLevel(true)
	
	
	#### IF PLAYER HAS NEARBY INTERACT OBJECT, ACTIVATE IT
	if Input.is_action_just_pressed("E"):
		States.activateInteractObject(self)
		

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
	
	print("________________")
	
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
		
		#### INTERACT OBJECT VISUAL STUFF ON TURN
		States.clearInteractObject() ## CLEAR
		for obj in getObjects():
			obj.startTurn() ## SET CURRENT OBJ
		ui.showInteractObjectInfo() ## SHOW CURRENT
	
	#### AFTER PLAYER ACTION	
	if previous != null:
		if previous.isPlayer:
			print("This message plays after player turn")
			lineOfSight.passTurn()  #### Deletes Visual Ranged Shoot Lines
			$AStarGridNode.passTurn() #### Deletes Navigation Lines
			ui.toggleHelp(false)
		
	next.startTurn()
			
	
	
	


func updateVisuals():
	ui.updateVisualsOnTurn()
	
	
#### CREATE LIST OF CURRENT TARGETS
func updateTargeting():		
	if not is_instance_valid(player):
		return
		
	$Utilities/Targeting.createTargetingDict()
	$Utilities/Targeting.autoSetTarget()
	ui.showTargetCreature(player.selectedTarget)
	
	
#### FOG OF WAR STUFF??
func handleFogOfWar():
	
	if turnOffFogOfWar:
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
func resetLevel(isValidClear:bool):
	
	isMapKilled = true
	game.storedPlayer = player
	$Creatures.remove_child(player)
	
	if isValidClear:
		game.startNewLevel()
	else:
		game.generateLevel()
		
	self.queue_free()


#### RANDOMIZE A GRAPHICS VALUE (It's a TILE ATLAS OFFSET)
#### 0 = CASTLE  |  1 = FOREST  |  2 = DESERT
func setLevelTileGraphics():
	
	#var graphicsValue = randi_range(0,2)
	for room in getRooms():
		room.setTileGraphics(dungeonInfo.biome)


############################################################
#### BOONS

#### CALLED FROM CreatureMovement.HandleMove
#### VIA WORLD SCENE -> To All Creatures
func triggerBoonAdjacentStep(creature:Node):
	for c in getCreatures():
		if not c == creature:
			c.triggerBoonAdjacentStep(creature)


func triggerBoonCreatureDeath(creature:Node):
	for c in getCreatures():
		if not c == creature:
			c.triggerBoonCreatureDeath(creature)

###################################################################
		
func getRooms():
	return $Rooms.get_children()

func getCreatures():
	return $Creatures.get_children()


func getObjects():
	return $Objects.get_children()


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


func getVisibleTiles():
	return lineOfSight.visibleTiles

	
	

func _on_dumb_timer_timeout() -> void:
		
	var rect = voidTilemap.get_used_rect()
	rect.position *= 32
	rect.size *= 32
	prints("rect: ", rect)  
	navigation_polygon.baking_rect = rect
	
	await $AStarGridNode.setupGrid()
	bake_navigation_polygon(true)
	
	
		

func _on_bake_finished() -> void:
	
	await get_tree().process_frame
	
	#### SOMETIMES THE NAVMESH BAKING FAILS
	if navigation_polygon.get_vertices().size() <= 0:
		print("Retrying navmesh bake")
		#bake_navigation_polygon(true)
		resetLevel(false)
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
