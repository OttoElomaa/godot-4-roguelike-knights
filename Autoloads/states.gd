extends Node


enum InputStates {
	NONE, EXPLORE, LOOK,
}

var GameState: InputStates = InputStates.EXPLORE



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
