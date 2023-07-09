extends AnimatedSprite2D

var weapon := 0

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
			if weapon > 0:
				play("walk_down_sword")
			else:
				play("walk_down")
		Vector2i(0, -1):
			play("walk_up")
		Vector2i(1, 0):
			if weapon > 0:
				play("walk_left_sword")
			else:
				play("walk_left")
			scale.x = -1
		Vector2i(-1, 0):
			if weapon > 0:
				play("walk_left_sword")
			else:
				play("walk_left")

	if lerp > 0:
		lerp = clampf(lerp - dt / %AITimer.wait_time, 0.0, 1.0)
	else:
		stop()

	%EnemyGoals.add_goal(self, 8)

	%PlayerGoals.finish()
	%PlayerHazards.finish()
	%EnemyGoals.finish()

func ai_step():
	map_pos = $Pathfinder.path_next(map_pos)
