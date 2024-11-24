class_name TileMapManager extends Node2D

const GROUND_TYPE: String = "GroundType"
const GROUND_INDOORS: int = 0
const GROUND_SNOW: int = 1

@export var ground_tiles: TileMapLayer

func get_tile_custom_data(tilemap_layer: TileMapLayer, tile_pos, custom_data):
	var tile_data: TileData = tilemap_layer.get_cell_tile_data(tile_pos)
	if tile_data: return tile_data.get_custom_data(custom_data)
	else: return false
