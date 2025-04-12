extends Node2D



#### CREATURES

var Orc: PackedScene = load("res://Creatures/Orc.tscn")
var Slime: PackedScene = load("res://Creatures/Slime.tscn")
var SkeletonArcher: PackedScene = load("res://Creatures/SkeletonArcher.tscn")
var DarkHealer: PackedScene = load("res://Creatures/DarkHealer.tscn")
var HoundMaster: PackedScene = load("res://Creatures/Houndmaster.tscn")
var SkullMage: PackedScene = load("res://Creatures/SkullMage.tscn")

var OrcWarlord: PackedScene = load("res://Creatures/OrcWarlord.tscn")

#### ROOMS

var cavern1: PackedScene = load("res://Rooms/Detached/Cavern/Cavern01.tscn")
var cavern2: PackedScene = load("res://Rooms/Detached/Cavern/Cavern02.tscn")
var cavern3: PackedScene = load("res://Rooms/Detached/Cavern/Cavern03.tscn")

var cells1: PackedScene = load("res://Rooms/Detached/Cells/Cells01.tscn")

var temple1: PackedScene = load("res://Rooms/Detached/Temple/Temple01.tscn")

#### OBJECTS

var ChestObj: PackedScene = load("res://Interactables/Chest.tscn")




func createRandomCreature() -> Node:
	
	var rng = randi_range(1,6)
	match rng:
		1:
			return Orc.instantiate()
		2:
			return Slime.instantiate()
		3:
			return SkeletonArcher.instantiate()
		4:
			return DarkHealer.instantiate()
		5:
			return HoundMaster.instantiate()
		6:
			return SkullMage.instantiate()
			
	return Orc.instantiate()
	


func createRandomBoss() -> Node:
	
	return OrcWarlord.instantiate()



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
