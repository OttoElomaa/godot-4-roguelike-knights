extends Node



var skill:Node = null
var actor:Node = null

@export var focusGain := 0
@export var focusSpend := 0
@export var focusEnhance := 0



func setup(skill):
	self.skill = skill
	self.actor = skill.actor
