extends Node2D

class_name Creature


enum BoonTypes {
	NONE, SELF_STEP, ADJACENT_STEP, RECEIVE_PHYS_ATTACK, CREATURE_DEATH
}


var world:Node = null
var grid:Node = null
var aStarGrid:AStarGrid2D = null
var player:Node = null

var gridPosition := Vector2i.ZERO


@export var isEnemy := true
@export var isPlayer := false

var isVisible := false
var isStationary := true

@export var creatureName := ""	


#### FOR MOVEMENT ANIMATION
var newPos:Vector2 = Vector2i.ZERO
var t := 0.0
var isMoving := false

var isOverworld := false

@onready var movementComponent := $CreatureMovement
@onready var status := $StatusEffects

@onready var stats:CreatureStats:
	get:
		return $Stats

var UnarmedWeapon:PackedScene = load("res://Items/We-Unarmed.tscn")


	
func setup(world:Node):
	
	self.world = world
	setupHelp()
	


func setupHelp():
	
	self.grid = world.grid
	self.player = world.player
	
	$Stats.setup(self)
	$StatusEffects.setup(self)
	
	$HealthBar.setup(self)
	
	$CreatureMovement.setup(self)
	$AnimationComponent.setup(self)
	
	#### SKILLS SETUP
	for skill in $Skills.get_children():
		skill.setup(self)
	
	#### EQUIPMENT SETUP
	$Equipment.setup(self)
	if $Equipment/Weapons.get_child_count() == 0:
		var unarmedW = UnarmedWeapon.instantiate()
		equip(unarmedW, true)


func _physics_process(delta: float) -> void:
	
	if not world:
		return
	elif world.isMapKilled:
		return
	
	if Input.is_action_just_pressed("P"):
		creatureMove()
	
	if isMoving:
		
		t += delta * 2.5
		position = position.lerp(newPos, t)
		
		if position == newPos:
			prints("movement goal reached, ", creatureName)
			isMoving = false	
			t = 0.0	
	
	
func creatureMove():
	
	#### TARGETING: ALLIES TARGET ENEMIES, AND VICE VERSA
	var targets = world.getEnemies()
	if isEnemy:
		targets = world.getAllies()
		
	var movementTarget = GridTools.findClosestCreature(self, targets)
	if movementTarget == null:
		movementTarget = world.player
	
	#### ADJACENT CREATURES DON'T MOVE	
	if GridTools.getEntityGridDistance(self, movementTarget) < 2:
		return
	
	#### CREATURE CAN MOVE IN THESE DIRECTIONS
	var allowedDirs := [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT, Vector2i.RIGHT,
	 Vector2i(1,1),Vector2i(-1,-1),Vector2i(-1,1),Vector2i(1,-1) ] 

	#### GET A LINE OF THE PATH FROM SELF TO TARGET (PLAYER)
	var line: Line2D = world.aStar.createPathBetween(self, movementTarget)
	line.hide()  ## DEBUG: SHOW/HIDE LINE
	
	if line.points.size() < 2:  ## NO LINE WAS MADE -> STOP
		return
	
	#### COMPARE TARGET POSITION TO CREATURE POSITIONS
	#### ROUND FROM 0.777..-> 1, 0.23412..-> ZERO
	var dir = position.direction_to(line.points[1])
	dir = Vector2i(round(dir.x), round(dir.y)) 
	
	#### TARGET GRID POSITION IS CURRENT POS + DIR
	if not dir in allowedDirs:
		assert(1==2,"WHAT THE SHIT, MOVEMENT")
		return
	var targetGridPos = gridPosition + Vector2i(dir)
	
	movementComponent.handleMove(dir)  ## MOVE
	line.remove_point(0)
	
	
	
func checkValidity() -> bool:
	if not is_instance_valid(self):
		return false
	if self.is_queued_for_deletion():
		return false
	return true
	
	

func startTurn():
	
	world.ui.deleteInitialRow()  ## DELETES INITIAL MESSAGES AT TURN START
	world.ui.clearCaveats()    ## Caveats are SKILL SPECIFIC
	
	#### FOR STAND-STILL BOONS
	isStationary = true
	
	if isOverworld:
		return
		
	#### EXIT REACHED: DO NOTHING
	if isPlayer:
		if gridPosition == world.exitGridPos:
			print("EXIT REACHEDDDDDDDD")
			world.resetLevel()
			return
	
	#### PLAYER OR SELF DEAD: DO NOTHING		
	if not world.player.checkValidity():
		return
	if not self.checkValidity():
		return	
	
	#### MAINTENANCE ON EACH TURN START
	#$Stats.turnStartUpdate()    # Reset Stats
	$StatusEffects.modifyStats(stats)
	
	#### VISUAL UPDATES ON TURN START
	$HealthBar.updateVisual(stats.health, stats.guard)
	if isPlayer:
		world.updateVisuals()
		world.updateTargeting()
		world.ui.updateVisualsOnTurn()
		
	
	prints(creatureName, " valid, takes action")
	#### TICK COOLDOWNS ETC ON-TURN EFFECTS ON SKILL NODES
	for skill in getSkills():
		var pointlessReturn = skill.passTurn()
		#if isPlayer:
		prints("tick! ", skill.getCooldown())
	
	$StatusEffects.tickStatus()
	
	#### SKIP TURN IF STUNNED. IF PLAYER, PASS SOME TIME
	if $StatusEffects.isStunned:
		if isPlayer:
			$StunnedWaitTimer.start()
		else:
			finishTurn()
		
	#### PLAYER PASSES TURN AFTER TAKING ACTION, SO DO NOTHING NOW
	if isPlayer:
		return
		
	
	#### DON'T DO ANYTHING IF DEAD
	if $Stats.health.current <= 0:
		return
	
	#### DON'T DO ANYHTHING IF AWAY FROM PLAYER
	#### SO ALL ALLIES/ENEMIES/ETC FREEZE WHEN FAR AWAY
	if not world.debugImmortalPlayer:
		if GridTools.getEntityGridDistance(self, player) > 12:
			finishTurn()
			return
	
	###################################################
	#### PICK TARGET
	#chooseTarget()
	#### TRY TO USE A SKILL
	if useSkills():
		finishTurn()
		return
		
	#### TRY TO MOVE	
	creatureMove()
	
	#### FINISH TURN IF NOTHING WAS DONE??
	finishTurn()
	


func finishTurn():
	world.callNextTurnAction(self)


#### TRY USING EACH SKILL IN SKILLS NODE
func useSkills() -> bool:
	
	for skill in $Skills.get_children():
		world.ui.clearCaveats() ## Caveats are SKILL SPECIFIC
		if skill.activate() == true:
			return true
	return false



func takeDamage(amount:int):
	$Stats.takeDamage(amount)
	$AnimationComponent.playMeleeHit()



func handlePhysicalHit(damage:int):
	$Stats.handlePhysicalHit(damage)



func recoverHealth(amount: int):
	$Stats.recoverHealth(amount)
	


func hasFullHealth():
	var he = stats.health
	return he.current >= he.max	



func addStatus(status:Node):
	#### NULL VALUE USED WHEN STATUS EFFECT DELETES ITSELF
	if status == null:
		$StatusEffects.modifyStats(stats)
		world.ui.updatePlayerPanel()
		return
	
	#### OTHERWISE, ADD STATUS AND UPDATE MY STATS
	$StatusEffects.addStatus(status)
	$StatusEffects.modifyStats(stats)
	world.ui.updatePlayerPanel()



func equip(item: Node, toWear: bool):
	$Equipment.equip(item, toWear)


#### FOR NOW, JUST GET WEAPON IN FIRST SPOT
func getWeapon():
	return $Equipment/Weapons.get_child(0)


##########################################################################################
#### THIS RECEIVES A STATRESOURCE, STATS.HEALTH, WITH VALUES 'CURRENT' AND 'MAX'
func updateHealthBar(health):
	$HealthBar.updateVisual(health, stats.guard)


func playMovementWobble():
	$SpriteAnimations.play("MovementWobble")


func playAttackAnimation():
	
	if isEnemy:
		$SpriteAnimations.play("EnemyAttack")
	else:
		$SpriteAnimations.play("AllyAttack")
	
	
#########################################################################
#### BOONS

#### CALLED FROM CreatureMovement.HandleMove
func triggerBoonSelfStep():
	for boon in status.get_children():
		if boon.isBoon:
			boon.triggerBoons(BoonTypes.SELF_STEP, self)

#### CALLED FROM CreatureMovement.HandleMove
#### VIA WORLD SCENE -> To All Creatures			
func triggerBoonAdjacentStep(creature:Node):
	
	#### LOGIC: IF CREATURE IS ADJACENT
	var myAdjacentC:Array = grid.getAdjacentCreatures(self)
	if myAdjacentC.is_empty():
		return		
	if not creature in myAdjacentC:
		return
	
	#### PASS IT TO BOONS
	for boon in status.get_children():
		if boon.isBoon:
			prints("Adjacent step. Boon haver %s finds adjacent creatures: " % creatureName, myAdjacentC)
			boon.triggerBoons(BoonTypes.ADJACENT_STEP, self)
		

######################################################################
	
	
func getNavigator():
	return $RangedNavigator
	

func getSkills():
	return $Skills.get_children()


func getHealth():
	return $Stats.health.current



func _on_mouse_area_mouse_entered() -> void:
	
	if not world:
		return
	if world.isOverworld:
		return
	
	prints("Mouse entered: ", creatureName)
	world.ui.showMouseLookCreature(self)


func _on_stunned_wait_timer_timeout() -> void:
	finishTurn()
