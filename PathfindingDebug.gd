extends Control

@onready var pathfinding := $".."

func _draw():
	for x in range(Global.map_size):
		for y in range(Global.map_size):
			var pos := Vector2i(x,  y)
			var val: int = pathfinding.get_cell(pos)
			if val < 0: continue

			var scene_pos: Vector2 = pathfinding.tiles.map_to_local(pos) + pathfinding.tiles.global_position
			draw_string(get_theme_font(""), scene_pos, str(val))
