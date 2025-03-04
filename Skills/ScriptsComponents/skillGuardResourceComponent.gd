extends Node



var skill:Node = null
var actor:Node = null

@export var guardGain := 0
@export var guardCost := 0
@export var guardEnhance := 0



func setup(skill):
	self.skill = skill
	self.actor = skill.actor



func setSkillResources(skill):
	
	skill.guardGain = guardGain
	skill.guardCost = guardCost
	skill.guardEnhance = guardEnhance
