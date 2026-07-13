class_name DungeonGenResult
extends Resource

# TYPED result from DungeonGeneratorAStar.generate().
# procgen_rooms: ROOT tile -> Array[Vector2i] floor tiles. [] value = POINT-ONLY room (no floor).

@export var path_tiles: Array[Vector2i] = []
@export var prefab_centers: Array[Vector2i] = []
# inspects as UNTYPED Dictionary, but always holds ROOT tile -> Array[Vector2i].
@export var procgen_rooms: Dictionary = {}


# FLAT union of every procgen floor tile. handy for bulk-painting one TileMapLayer.
func all_room_floors() -> Array[Vector2i]:
	var allTiles: Array[Vector2i] = []
	for tiles in procgen_rooms.values():
		allTiles.append_array(tiles)
	return allTiles


# TYPED list of procgen ROOT tiles (replaces the old procgen_centers array).
func procgen_roots() -> Array[Vector2i]:
	var roots: Array[Vector2i] = []
	roots.append_array(procgen_rooms.keys())
	return roots
	
	
