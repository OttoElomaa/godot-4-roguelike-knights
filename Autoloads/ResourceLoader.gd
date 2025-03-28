extends Node2D


var Orc: PackedScene = load("res://Creatures/Orc.tscn")
var Slime: PackedScene = load("res://Creatures/Slime.tscn")
var SkeletonArcher: PackedScene = load("res://Creatures/SkeletonArcher.tscn")
var DarkHealer: PackedScene = load("res://Creatures/DarkHealer.tscn")
var HoundMaster: PackedScene = load("res://Creatures/Houndmaster.tscn")

var OrcWarlord: PackedScene = load("res://Creatures/OrcWarlord.tscn")

var cavern1: PackedScene = load("res://Rooms/Detached/Cavern/Cavern01.tscn")
var cavern2: PackedScene = load("res://Rooms/Detached/Cavern/Cavern02.tscn")
var cavern3: PackedScene = load("res://Rooms/Detached/Cavern/Cavern03.tscn")

var cells1: PackedScene = load("res://Rooms/Detached/Cells/Cells01.tscn")

var temple1: PackedScene = load("res://Rooms/Detached/Temple/Temple01.tscn")

var InteractObj: PackedScene = load("res://RoomItems/InteractObject.tscn")




func createRandomCreature() -> Node:
	
	var rng = randi_range(1,5)
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
	
	return InteractObj.instantiate()
