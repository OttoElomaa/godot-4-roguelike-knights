extends Node2D



var world: Node = null
var player: Node = null

var equipItem:Node = null
var unequipItem:Node = null
var currentSlot:Node = null


func setup(world: Node):
	self.world = world
	player = world.player



func getItems() -> Array:
	return $Items.get_children()


#### FOR NON-PLAYERS
func creatureEquip(creature:Node, item:Node):
		
	var itemToUnequip:Node = creature.getEquipItemInSameSlot(item)
	var slot:Node = creature.getSameSlotAsItem(item)
	
	if itemToUnequip:
		print("Item to unequip while equipping: " + itemToUnequip.itemName)
		slot.remove_child(itemToUnequip)
		
	slot.add_child(item)
	item.setup(creature)



func playerEquip(item:Node):
	
	var itemToUnequip:Node = player.getEquipItemInSameSlot(item)
	var slot:Node = player.getSameSlotAsItem(item)
	
	#### SWAP THE ITEMS' POSITIONS
	if itemToUnequip:
		print("Item to unequip while equipping: " + itemToUnequip.itemName)
		itemToUnequip.reparent($Items)
	
	item.reparent(slot)
	item.setup(player)

		

func playerUnequip(item:Node):
	pass
