extends Sprite2D

var _pos = Vector2i(0, 0)

func _process(delta):
	var tile_size = get_parent().tile_set.tile_size
	position = _pos * tile_size + tile_size / 2

	var p = %PathfindingTracker
	p.goal(self, 10)
	print("goal")
	print(Engine.get_physics_frames())
	p.finish()
	print("finish")

func _input(event):
	if event is InputEventKey && event.pressed:
		var d = get_parent().get_cell_tile_data(0, _pos)
		match event.key_label:
			KEY_W: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE) == d.terrain: _pos.y -= 1
			KEY_S: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE) == d.terrain: _pos.y += 1
			KEY_A: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE) == d.terrain: _pos.x -= 1
			KEY_D: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE) == d.terrain: _pos.x += 1
