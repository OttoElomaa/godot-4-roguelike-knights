extends Node


enum InputStates {
	EXPLORE, LOOK,
}

var GameState: InputStates = InputStates.EXPLORE



func handleLook() -> bool:
	
	if GameState == InputStates.LOOK:
		GameState = InputStates.EXPLORE
		return false
	else:
		GameState = InputStates.LOOK
		return true
