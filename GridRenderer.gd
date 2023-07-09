extends Node2D

const GRID = Color(0.1, 0.1, 0.1, 0.08)
func _draw():
	var rect = get_parent().get_used_rect()
	var scale = get_parent().tile_set.tile_size
	rect.position *= Vector2i(1, 1)
	var from = rect.position
	var to = rect.position + rect.size
	var x = from.x
	while true:
		var sy = sign(to.y - from.y)
		draw_line(Vector2i(x, from.y - sy) * scale, Vector2i(x, to.y + sy) * scale, GRID)
		if x == to.x: break
		x += sign(to.x - x)
	var y = from.y
	while true:
		var sx = sign(to.x - from.x)
		draw_line(Vector2i(from.x - sx, y) * scale, Vector2i(to.x + sx, y) * scale, GRID)
		if y == to.y: break
		y += sign(to.y - y)
		
	#draw_line(rect.position * scale, rect.position * scale + rect.size * scale, Color.RED)
