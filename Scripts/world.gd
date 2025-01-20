extends NavigationRegion2D


var game:Node = null
var currentRoom: Node = null
@onready var grid := $GridController
@onready var lookTool := $Utilities/LookTool

var firstRoom := load("res://Scenes/BaseRoom.tscn")
var SecondRoom := load("res://Rooms/Basic/EntranceWest/BasicWestEast01.tscn")
var TestRoom := load("res://Rooms/Basic/EntranceWest/TestRoom01.tscn")




func startGame(game):

	self.game = game
	getPlayer().setup(self)

	getUi().displayPlayerSkills(getPlayer())
	
	
	#### ROOMS STUFF
	currentRoom = firstRoom.instantiate()
	var secondRoom = TestRoom.instantiate()
	
	$Rooms.add_child(currentRoom) 
	$Rooms.add_child(secondRoom) 
	
	#var secondRoom = SecondRoom.instantiate()
	#$World/Rooms.add_child(secondRoom)
	
	
	
	for room in getRooms():
		room.setup(self)
		
	currentRoom.placeOnMetaGrid(Vector2.ZERO)
	secondRoom.placeOnMetaGrid(Vector2i.RIGHT)
	
	$GridController.setup(self)
	
	currentRoom.randomizeTileGraphics()
	secondRoom.randomizeTileGraphics()
	
	secondRoom.startGameAtRoom(getPlayer())
	
	#### NAV STUFF
	$AStarGridNode.setup(self)
	$AStarGridNode.setupGrid()
	
	#### LINE OF SIGHT SETUP
	set_navigation_layer_value(1, true)
	bake_navigation_polygon(true)
	
	#### ADD CREATURES TO SPAWN LOCATIONS
	#### CREATURES ARE SETUP IN PopulateCreatures()
	var creatures: Array = []
	for room in $Rooms.get_children():
		creatures.append_array(room.populateCreatures() )
	for creature in creatures:
		$Creatures.add_child(creature)
		
		
	lineOfSightStuff()
		
		
	

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
	
	bake_navigation_polygon(true)
	
	
	for creature in getCreatures():
		if creature != getPlayer():
			creature.passTurn()
	
	lineOfSightStuff()
	
	
#### FOG OF WAR STUFF??
func lineOfSightStuff():	
	
	var playerPos: Vector2i = getPlayer().gridPosition
	#for coord:Vector2i in grid.getCoordsInRange(playerPos, 100):
	
	#### SET ALL UNSEEN WALL/FLOOR TILES AS HIDDEN
	for coord:Vector2i in grid.nonVoidTiles:
		$Utilities/FogTiles.set_cell(coord, 0, Vector2i(0,0))
	
	var coordsToCheck := []
	var coords2:Array = grid.getCoordsInRange(playerPos, 15)
	for coord in coords2:
		if coord in grid.nonVoidTiles:
			coordsToCheck.append(coord)
	
	$AStarGridNode.lineOfSightInRange(playerPos, coordsToCheck, $Utilities/FogTiles)
	
	

func pathStuff(creature, target):
	return $AStarGridNode.pathStuff(creature, target)


func processLook():
	
	var showInfo := false
	
	if Input.is_action_just_pressed("ui_up"):
		lookTool.move(Vector2i.UP)
		showInfo = true
	elif Input.is_action_just_pressed("ui_down"):
		lookTool.move(Vector2i.DOWN)
		showInfo = true
	elif Input.is_action_just_pressed("ui_left"):
		lookTool.move(Vector2i.LEFT)
		showInfo = true	
	elif Input.is_action_just_pressed("ui_right"):
		lookTool.move(Vector2i.RIGHT)
		showInfo = true
	
	#### OPTION 1: NOTHING TO SHOW
	if not showInfo:
		return
		
	else:
		getUi().showLookInfo(self, lookTool)



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
	
	
func getUi():
	return $UI
