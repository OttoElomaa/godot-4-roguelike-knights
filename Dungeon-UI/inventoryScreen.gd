extends PanelContainer


@onready var ItemListScene: PackedScene = load("res://Dungeon-UI/ItemListScene.tscn")

@onready var scroll := $Margin/MainHbox/InventoryVbox/HBox/ItemList/Scroll
@onready var itemRows = scroll.get_node("Items")

@onready var itemView := $Margin/MainHbox/InventoryVbox/HBox/ItemView
@onready var itemViewIcon: TextureRect = itemView.get_node("Margin/VBox/Icon")
@onready var itemViewName: Label = itemView.get_node("Margin/VBox/Name")
@onready var itemViewDesc: Label = itemView.get_node("Margin/VBox/Description")

@onready var itemViewReplaceName: Label = itemView.get_node("Margin/VBox/ReplaceVBox/Name") 
@onready var itemViewReplaceDesc: Label = itemView.get_node("Margin/VBox/ReplaceVBox/Description") 

@onready var equipmentView := $Margin/MainHbox/EquipmentVbox/EquipRows
@onready var weaponInfo: Control = equipmentView.get_node("WeaponInfo")
@onready var headInfo: Control = equipmentView.get_node("HeadInfo")
@onready var bodyInfo: Control = equipmentView.get_node("BodyInfo")
@onready var handsInfo: Control = equipmentView.get_node("HandsInfo")



var selectionNum := 0
var selectedItem:Node = null

var world:Node = null
var player:Node = null


func setup(world):
	self.world = world
	self.player = world.player



func _process(delta: float) -> void:
	if States.GameState == States.InputStates.INVENTORY:
		processInventory()
	

func processInventory():
	
	if Input.is_action_just_pressed("ui_down"):
		cycleItems(1)
	elif Input.is_action_just_pressed("ui_up"):
		cycleItems(-1)


############################################################3

func updateInfo():
	updateItemList()
	updateEquipmentView()


func updateItemList():
	
	for i in getRowItems():
		i.queue_free()
	
	for i in PlayerInventory.getItems():
		addItemListScene(i)
	
	$MiniWaitTimer.start()


func updateEquipmentView():
	var weapon = player.getWeapon()
	weaponInfo.setup(weapon)
		
	for v in [headInfo, bodyInfo, handsInfo]:
		v.setup(null)


func handleSelectedItem():
	selectedItem.toggleFocus(true)
	updateItemView()
	
	

func updateItemView():
	
	itemViewName.text = selectedItem.itemName	
	itemViewIcon.texture = selectedItem.itemIcon
	
	var selItemScene = selectedItem.itemScene
	if not selItemScene:
		return
	
	itemViewDesc.text = selItemScene.getInfoString()
		
	var replaceItem = player.getEquipItemInSameSlot(selItemScene)
	if replaceItem:
		itemViewReplaceName.text = replaceItem.itemName
		itemViewReplaceDesc.text = replaceItem.getInfoString()


################################################################

		
		
func getRowItems() -> Array:
	return itemRows.get_children()


func addItemListScene(item:Node):
	
	var listItem:Node = ItemListScene.instantiate()
	itemRows.add_child(listItem)
	listItem.setup(item)
	

func _on_mini_wait_timer_timeout() -> void:
	
	if getRowItems().size() == 0:
		return
	
	
	selectionNum = 0
	selectedItem = getRowItems()[selectionNum]
	handleSelectedItem()
	




func cycleItems(amount:int):
	
	#### GET AMOUNT OF ITEMS IN LIST
	var listSize:int = itemRows.get_child_count()
	if listSize == 0:
		return
	
	#### POP THE SELECTION NUM UP/DOWN
	selectedItem.toggleFocus(false)
	selectionNum += amount
	
	#### PROCESS RESULT
	if selectionNum < 0:
		selectionNum = listSize - 1
	
	elif selectionNum > listSize - 1:
		selectionNum = 0
	
	selectedItem = getRowItems()[selectionNum]
	handleSelectedItem()
	
	var scrollPosition = selectionNum * selectedItem.size.x
	scroll.scroll_vertical = scrollPosition
	
