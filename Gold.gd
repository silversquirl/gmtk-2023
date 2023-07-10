extends Sprite2D

@onready var map: TileMap = $".."
@onready var map_pos: Vector2i:
	set(pos):
		map_pos = pos
		position = map.map_to_local(map_pos)

func _ready():
	map_pos = map.local_to_map(position)

func _process(delta):
	%PlayerGoals.add_goal(self, 30)
