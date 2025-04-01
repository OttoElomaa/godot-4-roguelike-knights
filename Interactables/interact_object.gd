extends GridObject



@export var isContainer := false
@export var objectName := "Object Name"

var world: Node = null
var player: Node = null



func setup(world: Node):
	self.world = world
	player = world.player
	

func startTurn():
	var containerPanel = $Panel
	if not GridTools.getEntityGridDistance(self, player) < 2:
		containerPanel.hide()
		return
		
	containerPanel.show()
	States.setInteractObject(self)
		

func activate():
	
	if isContainer:
		activateContainer()
	
	

func activateContainer():
	
	world.ui.addMessage("Opening the %s" % objectName, Color.WHITE)
