extends Sprite2D

@onready var map: TileMap = $".."
@onready var map_pos: Vector2i = map.local_to_map(position):
	set(pos):
		map_pos = pos
		position = map.map_to_local(map_pos)

func _ready():
	%AITimer.timeout.connect(ai_step)

func _process(delta):
	%PlayerHazards.add_goal(self, 10)

func ai_step():
	map_pos = $"../EnemyPathfinder".path_next(map_pos)
