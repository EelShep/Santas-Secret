class_name EnemyManager
extends Node


static var instance: EnemyManager
func _init() -> void:
	if instance == null:
		instance = self


func entity_position_to_coords(position):
	return tilemap.local_to_map(position + position_offset)

func register(tilemap: TileMapLayer, enemies: Array):
	self.tilemap = tilemap
	self.enemies = enemies
	if enemies:
		make_map(tilemap, enemies)
		show_map(tilemap)

func _process(delta):
	cleanup(delta)


var position_offset = Vector2(0, -5.0)

var enemies = []
var map = {}
var used_tiles = {}
var erase_timeout = 0.0
var tilemap: TileMapLayer = null

enum MapTileDataConnection {WALK, DROP, JUMP_UP, JUMP_ACROSS, JUMP_DIAGONAL}
enum MapTileDataKind {EMPTY, FULL, HALF, WALKABLE}
	

class MapTileData:
	var coords: Vector2i
	var kind: MapTileDataKind
	var neighbors: Array = []
	var connections: Array = []
	func _init(coords, kind, neighbors = [], connections = []):
		self.coords = coords
		self.kind = kind
		self.neighbors = neighbors
		self.connections = connections
		

func make_map(tilemap: TileMapLayer, enemies: Array):
	for x in range(tilemap.get_used_rect().position.x, tilemap.get_used_rect().position.x+tilemap.get_used_rect().size.x):
		for y in range(tilemap.get_used_rect().position.y, tilemap.get_used_rect().position.y+tilemap.get_used_rect().size.y):
			var coords = Vector2i(x,y)
			var kind = MapTileDataKind.EMPTY
			var data := tilemap.get_cell_tile_data(coords) as TileData
			for layer_id in 1: # TODO add additional layers for half-tiles
				if data and data.get_collision_polygons_count(layer_id) > 0:
					if data.is_collision_polygon_one_way(layer_id, 0):
						kind = MapTileDataKind.HALF
					else:
						kind = MapTileDataKind.FULL
			map[coords] = MapTileData.new(coords, kind)
	for x in range(tilemap.get_used_rect().position.x, tilemap.get_used_rect().position.x+tilemap.get_used_rect().size.x):
		for y in range(tilemap.get_used_rect().position.y, tilemap.get_used_rect().position.y+tilemap.get_used_rect().size.y):
			var coords = Vector2i(x,y)
			var ground = coords + Vector2i(0,1)
			if map[coords].kind == MapTileDataKind.EMPTY and ground in map and map[ground].kind in [MapTileDataKind.FULL, MapTileDataKind.HALF]:
				# this tile has ground under it
				map[coords].kind = MapTileDataKind.WALKABLE
	for coords in map:
		if map[coords].kind == MapTileDataKind.HALF:
			map[coords].kind = MapTileDataKind.EMPTY
	var visited = []
	for enemy in enemies:
		var queue = [entity_position_to_coords(enemy.position)]		
		while queue:
			var coords = queue.pop_front()
			if coords == Vector2i(2,0):
				pass
			if coords in visited:
				continue
			visited.append(coords)
			
			# add drops
			if map[coords].kind == MapTileDataKind.EMPTY:
				for y in range(tilemap.get_used_rect().size.y):
					if not coords + Vector2i(0, y) in map:
						break
					if map[coords + Vector2i(0, y)].kind == MapTileDataKind.WALKABLE:
						map[coords].neighbors.append(coords + Vector2i(0, y))
						map[coords].connections.append(MapTileDataConnection.DROP)
						queue.append(coords + Vector2i(0, y))
						break
				continue
			
			# add vertical jumps
			for y in range(1,3):
				if coords + Vector2i(0, -y) not in map or map[coords + Vector2i(0, -y)].kind == MapTileDataKind.FULL:
					break
				if map[coords + Vector2i(0, -y)].kind == MapTileDataKind.WALKABLE:
					map[coords].neighbors.append(coords + Vector2i(0, -y))
					map[coords].connections.append(MapTileDataConnection.JUMP_UP)
					queue.append(coords + Vector2i(0, -y))
			# add walkable neighbors (even if it's walking towards a drop)
			for x in [-1,1]:
				if coords + Vector2i(x, 0) not in map:
					continue
				if map[coords + Vector2i(x, 0)].kind == MapTileDataKind.WALKABLE:
					map[coords].neighbors.append(coords + Vector2i(x, 0))
					map[coords].connections.append(MapTileDataConnection.WALK)
					queue.append(coords + Vector2i(x, 0))
				elif map[coords + Vector2i(x, 0)].kind == MapTileDataKind.EMPTY:
					map[coords].neighbors.append(coords + Vector2i(x, 0))
					map[coords].connections.append(MapTileDataConnection.DROP)
					queue.append(coords + Vector2i(x, 0))
			# add gap jumps
			for x in [-1,1]:
				if coords + Vector2i(x, 0) not in map or map[coords + Vector2i(x, 0)].kind in [MapTileDataKind.WALKABLE, MapTileDataKind.FULL]:
					continue
				for delta in range(2,5):
					if not coords + Vector2i(x*delta, 0) in map:
						continue
					if map[coords + Vector2i(x*delta, 0)].kind == MapTileDataKind.WALKABLE:
						map[coords].neighbors.append(coords + Vector2i(x*delta, 0))
						map[coords].connections.append(MapTileDataConnection.JUMP_ACROSS)
						queue.append(coords + Vector2i(x*delta, 0))
						break
			# add diagonal jumps
			for y in range(1,3):
				if coords + Vector2i(0, -y) not in map or map[coords + Vector2i(0, -y)].kind == MapTileDataKind.FULL:
					break
				for x in [-1,1]:
					for delta in range(1,3):
						if coords + Vector2i(x*delta, -y) not in map or map[coords + Vector2i(x*delta, -y)].kind == MapTileDataKind.FULL:
							break
						if map[coords + Vector2i(x*delta, -y)].kind == MapTileDataKind.WALKABLE:
							map[coords].neighbors.append(coords + Vector2i(x*delta, -y))
							map[coords].connections.append(MapTileDataConnection.JUMP_DIAGONAL)
							queue.append(coords + Vector2i(x*delta, -y))
		
		
func free_tile(tile: Vector2i):
	used_tiles.erase(tile)

func cleanup(delta):
	# TODO find a better to free tiles
	erase_timeout += delta
	if erase_timeout > 1.0:
		used_tiles = {}


#func_sort_queue_by_tile_manhattan(a,b):
func manhattan_distance(a: Vector2i,b: Vector2i) -> int:
	return abs(a.x-b.x) + abs(a.y-b.y)

func make_plan(from: Vector2i, to: Vector2i, tile_owner: Node2D, ignore_occupancies=false, capabilities=[]):
	var queue = [[from, []]]
	var visited = []
	
	prints("make_plan", tile_owner, from, to, len(used_tiles))
	if from == to:
		return []
	var max_attempts = 100
	while queue:
		queue.sort_custom(func(a, b): return manhattan_distance(a[0], to) < manhattan_distance(b[0], to))
		var coords_path = queue.pop_front()
		var coords = coords_path[0]
		var path = coords_path[1].duplicate()
		
		max_attempts -= 1
		if max_attempts <=0:
			prints("make_plan failed with max attempts")
			return []

		
		if coords in used_tiles and not ignore_occupancies:
			continue
		path.append(coords)
		visited.append(coords)

		if coords == to:
			prints("successful plan", path, "attempts remaining", max_attempts, "queue len", len(queue))
			for i in path:
				used_tiles[i] = tile_owner
			return path
		#prints("neighbors", coords, map[coords].neighbors)
		if capabilities:  
			for i in len(map[coords].neighbors): 
				if not map[coords].connections[i] in capabilities:
					continue
				var neighbor = map[coords].neighbors[i]
				if neighbor in visited:
					continue
				queue.append([neighbor, path])

		else:
			for neighbor in map[coords].neighbors: 
				if neighbor in visited:
					continue
				queue.append([neighbor, path])
	return []


func project_to_walkable(from: Vector2i) -> Vector2i:
	var to = Vector2i(from)
	while true:
		if to not in map:
			break
		if map[to].kind == MapTileDataKind.WALKABLE:
			break
		to.y += 1
	return to
	

		
var show_map_items = {}
#func show_map(tilemap: TileMap):
func show_map(tilemap):
	for i in map:
		match map[i].kind:
			MapTileDataKind.WALKABLE:
				var node = $Walkable.duplicate()
				get_parent().add_child(node)
				node.position = tilemap.map_to_local(i)
				show_map_items[i] = node
			MapTileDataKind.EMPTY:
				var node = $Empty.duplicate()
				get_parent().add_child(node)
				node.position = tilemap.map_to_local(i)
				show_map_items[i] = node
func show_path(path: Array, annotation_color: Color = Color.AQUA):
	for i in show_map_items:
		show_map_items[i].modulate = Color.WHITE
	for i in path:
		show_map_items[i].modulate = annotation_color
	
