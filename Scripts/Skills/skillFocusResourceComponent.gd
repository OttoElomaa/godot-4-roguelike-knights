extends Node



var skill:Node = null
var actor:Node = null

@export var zealGain := 0
@export var zealCost := 0
@export var zealEnhance := 0



func setup(skill):
	self.skill = skill
	self.actor = skill.actor



func setSkillResources(skill):
	
	skill.zealGain = zealGain
	skill.zealCost = zealCost
	skill.zealEnhance = zealEnhance
