extends Sprite2D

@onready var map: TileMap = $".."
@onready var map_pos: Vector2i = map.local_to_map(position):
	set(pos):
		map_pos = pos
		position = map.map_to_local(map_pos)

func _process(delta):
	%PathfindingTracker.goal(self, 10)
	%PathfindingTracker.finish()

func _input(event):
	if event is InputEventKey && event.pressed:
		var d = map.get_cell_tile_data(0, map_pos)
		var delta = Vector2i(0, 0)
		match event.key_label:
			KEY_W: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE) == d.terrain: delta.y -= 1
			KEY_S: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE) == d.terrain: delta.y += 1
			KEY_A: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE) == d.terrain: delta.x -= 1
			KEY_D: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE) == d.terrain: delta.x += 1
		map_pos = map_pos + delta
