extends Node



@export var itemName := "Item Name"
@export var itemIcon:Texture = null

enum EquipTypes {
	NONE, WEAPON, HEAD, BODY, HAND
}

@export var equipType := EquipTypes.NONE

@export var topDamage := 0
@export var midDamage := 0
@export var lowDamage := 0


var creature:Node = null

func setup(creature:Node):
	self.creature = creature


func getRealDamage(actor:Node) -> int:
	
	var crit = actor.stats.crit.current
	
	return topDamage
