extends Node2D


var firstRoom := load("res://Scenes/BaseRoom.tscn")
var SecondRoom := load("res://Rooms/Basic/EntranceWest/BasicWestEast01.tscn")
var TestRoom := load("res://Rooms/Basic/EntranceWest/TestRoom01.tscn")

var currentRoom: Node = null

@onready var grid := $World/GridController





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	getPlayer().setup(self)
	


	
func startGame():
	
	#get_tree().change_scene_to_packed(firstRoom)
	$UI/StartButton.hide()
	
	#### ROOMS STUFF
	currentRoom = firstRoom.instantiate()
	var secondRoom = TestRoom.instantiate()
	
	$World/Rooms.add_child(currentRoom) 
	$World/Rooms.add_child(secondRoom) 
	
	#var secondRoom = SecondRoom.instantiate()
	#$World/Rooms.add_child(secondRoom)
	
	
	
	for room in $World/Rooms.get_children():
		room.setup(self)
		
	currentRoom.placeOnMetaGrid(Vector2.ZERO)
	secondRoom.placeOnMetaGrid(Vector2i.RIGHT)
	
	$World/GridController.setup(self)
	
	currentRoom.randomizeTileGraphics()
	secondRoom.randomizeTileGraphics()
	
	secondRoom.startGameAtRoom(getPlayer())
	
	#### NAV STUFF
	#aStarGrid.region = Rect2i(0,0, 100,100)
	#aStarGrid.cell_size = Vector2i(32,32)
	#aStarGrid.offset = Vector2i(16,16)
	#aStarGrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	#aStarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#aStarGrid.update()
	$World/AStarGridNode.setup(self)
	$World/AStarGridNode.setupGrid()
	
	var creatures: Array = []
	for room in $World/Rooms.get_children():
		creatures.append_array(room.populateCreatures() )
	for creature in creatures:
		$World/Creatures.add_child(creature)
		#creature.setup(self)
		
	

func _process(delta: float) -> void:
	
	
	if Input.is_action_just_pressed("O"):
		for node in $Disposables.get_children():
			node.queue_free()
	
	if Input.is_action_just_pressed("L"):
		
		#### ACTUAL LOOK STUFF
		var isLook = States.handleLook()
		$LookTool.gridPosition = getPlayer().gridPosition
	
		$UI.updateStateLabel(isLook)
		
	
	if Input.is_action_just_pressed("u"):
		for r in getRooms():
			r.randomizeTileGraphics()
			
	if States.GameState == States.InputStates.LOOK:
		processLook()
		


func passTurn():
	
	$World/AStarGridNode.passTurn()
	
	
	
	for creature in $World/Creatures.get_children():
		if creature != getPlayer():
			creature.passTurn()
	


func pathStuff(creature, target):
	return $World/AStarGridNode.pathStuff(creature, target)


func processLook():
	
	var showInfo := false
	
	if Input.is_action_just_pressed("ui_up"):
		$LookTool.move(Vector2i.UP)
		showInfo = true
	elif Input.is_action_just_pressed("ui_down"):
		$LookTool.move(Vector2i.DOWN)
		showInfo = true
	elif Input.is_action_just_pressed("ui_left"):
		$LookTool.move(Vector2i.LEFT)
		showInfo = true	
	elif Input.is_action_just_pressed("ui_right"):
		$LookTool.move(Vector2i.RIGHT)
		showInfo = true
	
	#### OPTION 1: NOTHING TO SHOW
	if not showInfo:
		return
		
	else:
		$UI.showLookInfo(self, $LookTool)
	
func getPlayer():
	return $World/Creatures/Player
	
func getGrid():
	return $World/GridController

func getAStar():
	return $World/AStarGridNode
		
func getRooms():
	return $World/Rooms.get_children()

func getCreatures():
	return $World/Creatures.get_children()
