extends Node


#### SOURCE: Godot Forums. How to load a scene from a filepath. sash-rc, Sep 2021

func load_scene(path, parent: Node) -> Node:
	
	var result: Node = null
	if ResourceLoader.exists(path):
		result = ResourceLoader.load(path).instance()
		if result:
			parent.add_child(result)
			
	return result
