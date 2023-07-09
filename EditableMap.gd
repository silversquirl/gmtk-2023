extends TileMap

signal map_update

func visible_size():
	return Vector2i(Global.map_size, Global.map_size) * tile_set.tile_size

var chain = []
func _input(event):
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			var current_tile = local_to_map(get_local_mouse_position())
			if (
				current_tile.x < 0 or current_tile.y < 0 or
				current_tile.x >= Global.map_size or current_tile.y >= Global.map_size
			): return
			if chain.is_empty():
				chain.push_back(current_tile)
			else:
				while len(chain) > 10:
					chain.pop_front()
				_draw_line_filling(chain[len(chain) - 1], current_tile, func(p): chain.push_back(p))

			if get_cell_tile_data(0, current_tile) == null:
				%SoundEffects/BlockBreak.play()
			set_cells_terrain_connect(0, chain, 0, 0)
			$GridRenderer.queue_redraw()

	if event is InputEventMouseButton and event.pressed == false and event.button_index == MOUSE_BUTTON_LEFT:
		chain = []
		map_update.emit()

func _draw_line_filling(start, end, f):
	var pos = start
	var t = 0
	while t < 10:
		t += 1
		f.call(pos)
		if pos == end: break
		var diff = end - pos
		if abs(diff.x) < abs(diff.y): pos.y += sign(diff.y)
		else: pos.x += sign(diff.x)

func _draw_line(start, end, f):
	var dx = end.x - start.x
	var dy = end.y - start.y
	var sx = sign(dx)
	var sy = sign(dy)
	dx *= sx
	dy *= -dy
	var error = dx + dy
	var x = start.x
	var y = start.y
	while true:
		f.call(Vector2i(x, y))
		if x == end.x && y == end.y: break
		var e2 = 2 * error
		if e2 >= dy:
			if x == end.x: break
			error += dy
			x += sx
		if e2 <= dx:
			if y == end.y: break
			error += dx
			y += sy

func passable(pos: Vector2i) -> bool:
	var tile := get_cell_tile_data(0, pos)
	return tile and tile.terrain == 0

func can_walk_to(pos: Vector2i, dir: Vector2i) -> bool:
	var tile := get_cell_tile_data(0, pos)
	if tile == null:
		return false
	var side: TileSet.CellNeighbor
	match dir:
		Vector2i(0, 1):
			side = TileSet.CELL_NEIGHBOR_BOTTOM_SIDE
		Vector2i(0, -1):
			side = TileSet.CELL_NEIGHBOR_TOP_SIDE
		Vector2i(1, 0):
			side = TileSet.CELL_NEIGHBOR_RIGHT_SIDE
		Vector2i(-1, 0):
			side = TileSet.CELL_NEIGHBOR_LEFT_SIDE
		_:
			assert(false)
	return tile.get_terrain_peering_bit(side) == tile.terrain
