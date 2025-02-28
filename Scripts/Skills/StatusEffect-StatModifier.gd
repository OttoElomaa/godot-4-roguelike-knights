extends Node


var effect:Node = null

@export var isActive := false

@export var armorModify := 0
@export var blockModify := 0
@export var evasionModify := 0

@export var critModify := 0


func setup(effect:Node):
	self.effect = effect


#### RECEIVING THE AFFECTED CREATURE'S STATS NODE, OPERATE ON IT DIRECTLY IN HERE
func modifyStats(stats:Node):
	
	if not isActive:
		return
		
	stats.armor.current += armorModify
	stats.block.current += blockModify
	stats.evasion.current += evasionModify
	
	stats.crit.current += critModify
