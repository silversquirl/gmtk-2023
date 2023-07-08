extends Control

@onready var pathfinding := get_parent()

func _draw():
	print("draw")
	print(Engine.get_physics_frames())
	for x in range(Global.map_size):
		for y in range(Global.map_size):
			var pos := Vector2i(x,  y)
			var val: int = pathfinding.get_cell(pos)
			if val < 0: continue

			var scene_pos: Vector2 = (pathfinding.tiles.map_to_local(pos) * pathfinding.tiles.scale) + pathfinding.tiles.position
			draw_string(get_theme_font(""), scene_pos, str(val))
