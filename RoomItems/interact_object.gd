extends GridObject



@export var isContainer := false

var world: Node = null
var player: Node = null



func setup(world: Node):
	self.world = world
	player = world.player
	

func startTurn():
	var containerPanel = $Canvas/Panel
	if GridTools.getEntityGridDistance(self, player) < 2:
		containerPanel.show()
	else:
		containerPanel.hide()
