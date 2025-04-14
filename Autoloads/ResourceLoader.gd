extends Node2D



#### CREATURES

#### ROOMS

var cavern1: PackedScene = load("res://Rooms/Detached/Cavern/Cavern01.tscn")
var cavern2: PackedScene = load("res://Rooms/Detached/Cavern/Cavern02.tscn")
var cavern3: PackedScene = load("res://Rooms/Detached/Cavern/Cavern03.tscn")

var cells1: PackedScene = load("res://Rooms/Detached/Cells/Cells01.tscn")

var temple1: PackedScene = load("res://Rooms/Detached/Temple/Temple01.tscn")

#### OBJECTS

var ChestObj: PackedScene = load("res://Interactables/Chest.tscn")



func loadRandomScene(folderPath:String) -> Node:
	
	var dir := DirAccess.open(folderPath)

	var file_names := dir.get_files()
	
	var size = file_names.size()
	var rng = randi_range(0, size - 1)
	var random_file := file_names[rng]
	
	var creature:PackedScene = load(folderPath + random_file)
	return creature.instantiate()


func createRandomCreature() -> Node:
	
	var folderPath := "res://Creatures/Enemies/"
	return loadRandomScene(folderPath)


func createRandomBoss() -> Node:
	
	var folderPath := "res://Creatures/Bosses/"
	return loadRandomScene(folderPath)



func createRandomRoom() -> Node:
	
	var scene:PackedScene = null
	match randi_range(0,4):
			0:
				scene = cavern1
			1:
				scene = cavern2
			2:
				scene = cavern3
			3:
				scene = cells1
			4:
				scene = temple1
				
	return scene.instantiate()



func createRandomInteractObj():
	
	return ChestObj.instantiate()
