extends AnimatedSprite2D

@onready var map: TileMap = $".."
var map_pos: Vector2i:
	set(pos):
		map_pos = pos
		position = map.map_to_local(map_pos)

func _ready():
	map_pos = map.local_to_map(position)

func _process(_dt):
	%EnemyGoals.add_goal(self, 8)

	%PlayerGoals.finish()
	%PlayerHazards.finish()
	%EnemyGoals.finish()

func _input(event):
	if event is InputEventKey and event.pressed:
		var d = map.get_cell_tile_data(0, map_pos)
		var delta = Vector2i(0, 0)
		match event.key_label:
			KEY_W: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE) == d.terrain: delta.y -= 1
			KEY_S: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE) == d.terrain: delta.y += 1
			KEY_A: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE) == d.terrain: delta.x -= 1
			KEY_D: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE) == d.terrain: delta.x += 1
			KEY_SPACE:
				delta = Vector2i(0, 0)
				ai_step()
		map_pos = map_pos + delta

func ai_step():
	map_pos = $Pathfinder.path_next(map_pos)
