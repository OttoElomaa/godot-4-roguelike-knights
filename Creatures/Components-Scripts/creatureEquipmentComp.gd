extends Node2D



enum EquipTypes {
	NONE, WEAPON, HEAD, BODY, HAND
}


var creature:Node = null
var world:Node = null



func setup(creature):
	self.creature = creature
	self.world = creature.world



func equip(item: Node, toWear: bool):
	
	var equipSlot:Node = null
	match item.equipType:
		
		EquipTypes.WEAPON:
			equipSlot = $Weapons
		EquipTypes.HEAD:
			equipSlot = $Head
		EquipTypes.BODY:
			equipSlot = $Body
		EquipTypes.HAND:
			equipSlot = $Hands
		EquipTypes.NONE:
			assert(1==2,"Equipment error??")
	
	
	
	#### REMOVES EQUIPPED ITEM
	if not toWear:
		equipSlot.remove_child(item)
		PlayerInventory.add_child(item)
	
	#### EQUIPS GIVEN ITEM -> CALLS ITSELF to UNEQUIP the current item	
	elif canEquipCheck(item):
		for e in equipSlot.get_children():
			equip( e, false )
		PlayerInventory.remove_child(item)
		equipSlot.add_child(item)
		item.setup(creature)



func canEquipCheck(item:Node) -> bool:
	
	return true
