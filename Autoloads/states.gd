extends Node


enum InputStates {
	NONE, EXPLORE, LOOK,
}

var GameState: InputStates = InputStates.EXPLORE

var currentInteractObject: Node = null



func inputModeOff():
	GameState = InputStates.NONE
	

func inputModeExplore():
	GameState = InputStates.EXPLORE


func handleLook() -> bool:
	
	if GameState == InputStates.LOOK:
		GameState = InputStates.EXPLORE
		return false
	else:
		GameState = InputStates.LOOK
		return true


func activateInteractObject(world:Node):
	
	if not currentInteractObject:
		world.ui.addMessage("Can't interact with any object.", Color.WHITE)
		return
	
	currentInteractObject.activate()
	

func clearInteractObject():
	
	currentInteractObject = null


func setInteractObject(object:Node):
	currentInteractObject = object
	
