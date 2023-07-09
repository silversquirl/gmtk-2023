extends AnimatedSprite2D

@onready var map: TileMap = $".."
var direction := Vector2i(0, 1)
var lerp := 0.0
@onready var map_pos: Vector2i = map.local_to_map(position):
	set(pos):
		if pos == map_pos: return
		direction = pos - map_pos
		lerp = 1
		map_pos = pos

func _ready():
	%AITimer.timeout.connect(ai_step)

func _process(dt):
	var offset := -lerp * Vector2(direction * map.tile_set.tile_size)
	position = map.map_to_local(map_pos) + offset

	scale.x = 1
	match direction:
		Vector2i(0, 1):
			play("walk_down")
		Vector2i(0, -1):
			play("walk_up")
		Vector2i(1, 0):
			play("walk_left")
			scale.x = -1
		Vector2i(-1, 0):
			play("walk_left")

	if lerp > 0:
		lerp = clampf(lerp - dt / %AITimer.wait_time, 0.0, 1.0)
	else:
		stop()

	%EnemyGoals.add_goal(self, 8)

	%PlayerGoals.finish()
	%PlayerHazards.finish()
	%EnemyGoals.finish()

#func _input(event):
#	if event is InputEventKey and event.pressed:
#		var d = map.get_cell_tile_data(0, map_pos)
#		var delta = Vector2i(0, 0)
#		match event.key_label:
#			KEY_W: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE) == d.terrain: delta.y -= 1
#			KEY_S: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE) == d.terrain: delta.y += 1
#			KEY_A: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE) == d.terrain: delta.x -= 1
#			KEY_D: if d.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE) == d.terrain: delta.x += 1
#		map_pos = map_pos + delta

func ai_step():
	map_pos = $Pathfinder.path_next(map_pos)
