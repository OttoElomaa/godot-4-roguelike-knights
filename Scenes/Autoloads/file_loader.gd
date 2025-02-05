extends Node2D


var Orc = load("res://Scenes/Creatures/Orc.tscn")
var Slime = load("res://Scenes/Creatures/Slime.tscn")
var SkeletonArcher = load("res://Scenes/Creatures/SkeletonArcher.tscn")
var DarkHealer = load("res://Scenes/Creatures/DarkHealer.tscn")
var HoundMaster = load("res://Scenes/Creatures/Houndmaster.tscn")

var OrcWarlord = load("res://Scenes/Creatures/OrcWarlord.tscn")


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
	match randi_range(0,2):
			0:
				scene = load("res://Rooms/Detached/Cavern/Cavern02.tscn")
			1:
				scene = load("res://Rooms/Detached/Cavern/Cavern01.tscn")
			2:
				scene = load("res://Rooms/Detached/Cells/Cells01.tscn")
	return scene.instantiate()
