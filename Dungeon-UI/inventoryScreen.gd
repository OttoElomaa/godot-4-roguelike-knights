extends PanelContainer


@onready var ItemListScene: PackedScene = load("res://Dungeon-UI/ItemListScene.tscn")

@onready var itemRows := $Margin/VBox/HBox/ItemList/Scroll/Items
@onready var itemView := $Margin/VBox/HBox/ItemView
@onready var itemViewIcon := $Margin/VBox/HBox/ItemView/Margin/VBox/Icon
@onready var itemViewName := $Margin/VBox/HBox/ItemView/Margin/VBox/Name

var selectionNum := 0
var selectedItem:Node = null


func _process(delta: float) -> void:
	if States.GameState == States.InputStates.INVENTORY:
		processInventory()
	

func processInventory():
	
	if Input.is_action_just_pressed("ui_down"):
		cycleItems(1)
	elif Input.is_action_just_pressed("ui_up"):
		cycleItems(-1)


func updateItemList():
	
	for i in getRowItems():
		i.queue_free()
	
	for i in PlayerInventory.getItems():
		addItemListScene(i)
	
	$MiniWaitTimer.start()
		
		
func getRowItems() -> Array:
	return itemRows.get_children()


func addItemListScene(item:Node):
	
	var listItem:Node = ItemListScene.instantiate()
	itemRows.add_child(listItem)
	listItem.setup(item)
	

func _on_mini_wait_timer_timeout() -> void:
	
	if getRowItems().size() == 0:
		return
	
	updateItemView(0)
	
	selectedItem = getRowItems()[0]
	selectedItem.toggleFocus(true)


func updateItemView(index:int):
	var items:Array = getRowItems()
	itemViewName.text = items[index].itemName	
	itemViewIcon.texture = items[index].itemIcon


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
	selectedItem.toggleFocus(true)
	updateItemView(selectionNum)
	
	var scrollPosition = selectionNum * selectedItem.size.x
	$Margin/VBox/HBox/ItemList/Scroll.scroll_vertical = scrollPosition
	
