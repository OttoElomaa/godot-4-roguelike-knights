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

@export var armor := 0


var creature:Node = null

func setup(creature:Node):
	self.creature = creature


func getRealDamage(actor:Node) -> int:
	
	var crit = actor.stats.crit.current
	var highLimit = clamp(crit, 0, 50)
	var midLimit = clamp(crit * 2, 0, 80)
		
	var randCrit = randi_range(0,100)
	var critText := "(Crit roll %d" % randCrit
	
	randCrit = 100 - randCrit
	var realDamage := lowDamage
	
	if randCrit < highLimit:
		realDamage = topDamage
		critText += " <- high)"
		
	elif randCrit < midLimit:
		realDamage = midDamage
		critText += " <- mid)"
	
	else:
		critText += " <- low)"
		
	actor.world.ui.addCaveat(critText)
	return realDamage



func getInfoString():
	if equipType == EquipTypes.WEAPON:
		return "Damage: %d / %d / %d" % [lowDamage, midDamage, topDamage]
	
	elif equipType != EquipTypes.NONE:
		return "Armor: %d" % armor
		
	return "Item description string"


	
