extends Node
class_name DungeonGeneratorAStar

# DUNGEON GENERATOR -- ASTAR VARIANT (Godot 4 / GDScript). version 2.
# PIPELINE: place prefabs -> place procgen -> MST over UNION -> carve corridors -> build procgen room dict.
# CORRIDORS: L_SHAPED, ASTAR_4WAY (orthogonal), ASTAR_8WAY (thin diagonals). no programmatic corner fill.
# RETURNS: DungeonGenResult (typed). procgen_rooms = ROOT tile -> floor tiles ([] = POINT-ONLY).

enum RoomStyle { RECTANGLE, BLOB }
enum CorridorStyle { L_SHAPED, ASTAR_4WAY, ASTAR_8WAY }

# STYLE toggles. show as dropdowns in inspector.
@export var room_style: RoomStyle = RoomStyle.RECTANGLE
@export var corridor_style: CorridorStyle = CorridorStyle.L_SHAPED

# PREFAB rooms (mutually exclusive). min_prefab_distance = the keep-apart area, so they never touch.
@export var prefab_room_count: int = 8
@export var min_prefab_distance: int = 8
@export var map_size: Vector2i = Vector2i(64, 64)

## TIGHTNESS: 0 = SPARSE (whole map), 1 = TIGHT (clustered).
@export_range(0.0, 1.0) var tightness: float = 0.3

## TANGLED: 0 = LINEAR (tree, no loops), 1 = many LOOPS.
@export_range(0.0, 1.0) var tangled: float = 0.0

## SEED: 0 = random each run, else DETERMINISTIC.
@export var rng_seed: int = 0

# PROCGEN rooms (optional). exist as path points; floor SIZE rolls in the range below.
## when TRUE, generate() places PROCGEN rooms and builds their floor dict.
@export var generate_room_floors: bool = false
@export var procgen_room_count: int = 6

## procgen floor SIZE range. roll of 0 = POINT-ONLY (no floor). set MAX = 0 to force all point-only.
@export var procgen_room_min_size: int = 3
@export var procgen_room_max_size: int = 7

## CLUSTER: 1 = HUG prefab centers, 0 = SCATTER across map. (outer bound)
@export_range(0.0, 1.0) var procgen_cluster: float = 0.6

## min distance PROCGEN origin keeps from EVERY prefab center. (inner bound)
@export var min_procgen_to_prefab: int = 1

## tile PIXEL size. only for get_point_path (WORLD coords). tile path ignores it.
@export var tile_pixel_size: Vector2 = Vector2(16, 16)

# INTERNAL working state. outputs are RETURNED as a DungeonGenResult.
var _path_tiles: Array[Vector2i] = []
var _prefab_centers: Array[Vector2i] = []
var _procgen_centers: Array[Vector2i] = []
var _path_set: Dictionary = {}
var _room_set: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _astar := AStarGrid2D.new()


# set core values from another SCRIPT. styles + sizes are plain properties, set directly.
func configure(
		p_prefab_count: int,
		p_min_distance: int,
		p_tightness: float,
		p_tangled: float,
		p_generate_room_floors: bool = false,
		p_procgen_count: int = 6,
		p_procgen_cluster: float = 0.6,
		p_min_procgen_to_prefab: int = 1) -> void:
	prefab_room_count = p_prefab_count
	min_prefab_distance = p_min_distance
	tightness = clampf(p_tightness, 0.0, 1.0)
	tangled = clampf(p_tangled, 0.0, 1.0)
	generate_room_floors = p_generate_room_floors
	procgen_room_count = p_procgen_count
	procgen_cluster = clampf(p_procgen_cluster, 0.0, 1.0)
	min_procgen_to_prefab = p_min_procgen_to_prefab


# MAIN entry. corridors span BOTH center lists. returns a typed DungeonGenResult.
func generate() -> DungeonGenResult:
	_path_tiles.clear()
	_prefab_centers.clear()
	_procgen_centers.clear()
	_path_set.clear()
	_room_set.clear()

	if rng_seed == 0:
		_rng.randomize()
	else:
		_rng.seed = rng_seed

	_place_prefab_rooms()
	if generate_room_floors:
		_place_procgen_rooms()

	# corridors connect the UNION of both center lists.
	var all_centers: Array[Vector2i] = []
	all_centers.append_array(_prefab_centers)
	all_centers.append_array(_procgen_centers)

	var edges := _connect_centers(all_centers)
	if corridor_style != CorridorStyle.L_SHAPED:
		_setup_astar()
	for e in edges:
		_carve_corridor(all_centers[e.x], all_centers[e.y])

	for tile in _path_set.keys():
		_path_tiles.append(tile)

	# pack into a FRESH result (own arrays, so a later generate() can't mutate it).
	var result := DungeonGenResult.new()
	result.path_tiles = _copy(_path_tiles)
	result.prefab_centers = _copy(_prefab_centers)
	if generate_room_floors:
		result.procgen_rooms = _build_procgen_rooms()
	return result


# scatter PREFAB centers. min-distance rule = NO STACKING.
func _place_prefab_rooms() -> void:
	if prefab_room_count <= 0:
		return

	var margin := procgen_room_max_size + 1
	var full_pos := Vector2i(margin, margin)
	var full_size := map_size - Vector2i(margin, margin) * 2
	var full_center := full_pos + full_size / 2

	# TIGHTNESS shrinks the spawn region toward center.
	var scale := lerpf(1.0, 0.45, tightness)
	var region_half := Vector2(full_size) * 0.5 * scale
	var region_pos := full_center - Vector2i(region_half)
	var region_size := Vector2i(region_half) * 2

	var attempts_per_room := 30
	for i in prefab_room_count:
		for attempt in attempts_per_room:
			var pos := Vector2i(
				_rng.randi_range(region_pos.x, region_pos.x + region_size.x),
				_rng.randi_range(region_pos.y, region_pos.y + region_size.y)
			)
			var ok := true
			for existing in _prefab_centers:
				if _dist(pos, existing) < float(min_prefab_distance):
					ok = false
					break
			if ok:
				_prefab_centers.append(pos)
				break
			# fail after all attempts = skip it. no infinite loop.


# scatter PROCGEN centers. footprints may STACK, but every ROOT tile is UNIQUE (safe dict keys).
func _place_procgen_rooms() -> void:
	if procgen_room_count <= 0:
		return

	var margin := procgen_room_max_size + 1
	# CLUSTER picks outer radius: high = hug prefabs, low = spread.
	var max_radius := float(maxi(map_size.x, map_size.y))
	var radius := lerpf(max_radius, float(min_prefab_distance), procgen_cluster)
	var attempts_per_room := 30

	for i in procgen_room_count:
		for attempt in attempts_per_room:
			var pos: Vector2i
			if _prefab_centers.is_empty():
				# nothing to hug = scatter across map.
				pos = Vector2i(
					_rng.randi_range(margin, map_size.x - margin),
					_rng.randi_range(margin, map_size.y - margin)
				)
			else:
				# point in a DISK around a random prefab center.
				var anchor := _prefab_centers[_rng.randi_range(0, _prefab_centers.size() - 1)]
				var angle := _rng.randf() * TAU
				var dist := _rng.randf() * radius
				var offset := Vector2(cos(angle), sin(angle)) * dist
				pos = anchor + Vector2i(offset)
				pos.x = clampi(pos.x, margin, map_size.x - margin)
				pos.y = clampi(pos.y, margin, map_size.y - margin)

			# REJECT if too close to a prefab OR if this root tile is already taken.
			if _far_enough_from_prefabs(pos) and not _procgen_centers.has(pos):
				_procgen_centers.append(pos)
				break


# TRUE if pos clears min_procgen_to_prefab from ALL prefab centers.
func _far_enough_from_prefabs(pos: Vector2i) -> bool:
	for c in _prefab_centers:
		if _dist(pos, c) < float(min_procgen_to_prefab):
			return false
	return true


# build ROOT tile -> floor tiles. SIZE rolls per room; 0 = point-only (empty tiles).
func _build_procgen_rooms() -> Dictionary:
	var rooms := {}
	for root in _procgen_centers:
		var size := _rng.randi_range(procgen_room_min_size, procgen_room_max_size)
		var tiles: Array[Vector2i] = []
		if size > 0:
			_room_set.clear()
			_carve_room(root, size)
			for t in _room_set.keys():
				tiles.append(t)
		rooms[root] = tiles
	return rooms


# MST (Prim) over centers, then add short leftover edges for TANGLED loops.
# edges hold INDICES into centers.
func _connect_centers(centers: Array[Vector2i]) -> Array[Vector2i]:
	var edges: Array[Vector2i] = []
	var n := centers.size()
	if n <= 1:
		return edges

	var in_tree: Array[bool] = []
	in_tree.resize(n)
	in_tree.fill(false)
	in_tree[0] = true
	var tree_count := 1

	while tree_count < n:
		var best_a := -1
		var best_b := -1
		var best_d := INF
		for a in n:
			if not in_tree[a]:
				continue
			for b in n:
				if in_tree[b]:
					continue
				var d := _dist(centers[a], centers[b])
				if d < best_d:
					best_d = d
					best_a = a
					best_b = b
		if best_b == -1:
			break
		in_tree[best_b] = true
		tree_count += 1
		edges.append(Vector2i(best_a, best_b))

	# TANGLED: add shortest leftover edges = loops.
	if tangled > 0.0:
		var candidates: Array = []
		for a in n:
			for b in range(a + 1, n):
				if not _has_edge(edges, a, b):
					candidates.append({
						"e": Vector2i(a, b),
						"d": _dist(centers[a], centers[b]),
					})
		candidates.sort_custom(func(x, y): return x.d < y.d)
		var extra := int(round(tangled * candidates.size() * 0.3))
		for i in min(extra, candidates.size()):
			edges.append(candidates[i].e)

	return edges


# pick corridor carver by STYLE.
func _carve_corridor(a: Vector2i, b: Vector2i) -> void:
	match corridor_style:
		CorridorStyle.ASTAR_4WAY, CorridorStyle.ASTAR_8WAY:
			_carve_corridor_astar(a, b)
		_:
			_carve_corridor_l(a, b)


# pick room carver by STYLE. size is guaranteed >= 1 here.
func _carve_room(center: Vector2i, size: int) -> void:
	match room_style:
		RoomStyle.BLOB:
			_carve_room_blob(center, size)
		_:
			_carve_room_rect(center, size)


# L SHAPE: horizontal run, then vertical run.
func _carve_corridor_l(a: Vector2i, b: Vector2i) -> void:
	var x := a.x
	var y := a.y
	while x != b.x:
		_add_tile(Vector2i(x, y), _path_set)
		x += signi(b.x - x)
	while y != b.y:
		_add_tile(Vector2i(x, y), _path_set)
		y += signi(b.y - y)
	_add_tile(Vector2i(x, y), _path_set)


# CONFIGURE the shared ASTAR grid once. grid ids ARE tile coords.
# 4WAY = DIAGONAL_MODE_NEVER (edge-adjacent), 8WAY = ALWAYS (thin). must UPDATE after settings.
func _setup_astar() -> void:
	_astar.region = Rect2i(Vector2i.ZERO, map_size)
	_astar.cell_size = tile_pixel_size
	_astar.diagonal_mode = (
		AStarGrid2D.DIAGONAL_MODE_ALWAYS if corridor_style == CorridorStyle.ASTAR_8WAY
		else AStarGrid2D.DIAGONAL_MODE_NEVER
	)
	_astar.update()

	# OBSTACLE HOOK: after update(), set_point_solid(tile) to route AROUND things.
	# endpoints (room centers) must NOT be solid or get_id_path returns EMPTY.


# ASTAR path -> stamp tiles. NO PATH (blocked) = fall back to L.
func _carve_corridor_astar(a: Vector2i, b: Vector2i) -> void:
	var path := _astar.get_id_path(a, b)
	if path.is_empty():
		_carve_corridor_l(a, b)
		return
	for tile in path:
		_add_tile(tile, _path_set)


# RECT room: solid size x size block on center.
func _carve_room_rect(center: Vector2i, size: int) -> void:
	var half := size / 2
	for x in range(center.x - half, center.x - half + size):
		for y in range(center.y - half, center.y - half + size):
			_add_tile(Vector2i(x, y), _room_set)


# BLOB room: overlapping DISCS (metaball) for organic cave shape. size = rough diameter.
# central mass keeps lobes CONNECTED.
func _carve_room_blob(center: Vector2i, size: int) -> void:
	var r := size * 0.5
	_stamp_disc(center, r * 0.7)
	var lobes := _rng.randi_range(3, 6)
	for i in lobes:
		var lobe_r := r * _rng.randf_range(0.45, 1.0)
		var max_off := r * 0.6
		var ox := roundi(_rng.randf_range(-max_off, max_off))
		var oy := roundi(_rng.randf_range(-max_off, max_off))
		_stamp_disc(center + Vector2i(ox, oy), lobe_r)


# stamp a filled DISC into the room set.
func _stamp_disc(c: Vector2i, radius: float) -> void:
	if radius < 0.5:
		_add_tile(c, _room_set)
		return
	var ri := ceili(radius)
	var r2 := radius * radius
	for dx in range(-ri, ri + 1):
		for dy in range(-ri, ri + 1):
			if float(dx * dx + dy * dy) <= r2:
				_add_tile(Vector2i(c.x + dx, c.y + dy), _room_set)


# add tile to target set if IN BOUNDS.
func _add_tile(tile: Vector2i, target: Dictionary) -> void:
	if tile.x < 0 or tile.y < 0 or tile.x >= map_size.x or tile.y >= map_size.y:
		return
	target[tile] = true


# fresh TYPED copy of a tile array (so results don't share mutable state).
func _copy(src: Array[Vector2i]) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	out.append_array(src)
	return out


# EUCLIDEAN distance between two tiles.
func _dist(a: Vector2i, b: Vector2i) -> float:
	return Vector2(a).distance_to(Vector2(b))


# TRUE if edge a-b already exists (either order).
func _has_edge(edges: Array, a: int, b: int) -> bool:
	for e in edges:
		if (e.x == a and e.y == b) or (e.x == b and e.y == a):
			return true
	return false
