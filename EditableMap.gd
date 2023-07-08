extends TileMap

const HEIGHT = 256
const WIDTH = HEIGHT

func visible_size():
	return Vector2i(WIDTH, HEIGHT) * tile_set.tile_size

var chain = []
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT: chain = []
	if event is InputEventMouseMotion || event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			var current_tile = local_to_map(get_local_mouse_position())
			if current_tile.x >= WIDTH || current_tile.y >= HEIGHT: return
			if chain.is_empty():
				chain.push_back(current_tile)
			else:
				while len(chain) > 10:
					chain.pop_front()
				_draw_line_filling(chain[len(chain) - 1], current_tile, func(p): chain.push_back(p))
				
			set_cells_terrain_connect(0, chain, 0, 0)

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