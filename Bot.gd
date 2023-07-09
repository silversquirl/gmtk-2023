extends Sprite2D

const CollisionDetector = preload("res://CollisionDetector.gd")
const Player = preload("res://Player.gd")

@export var health := 20
@export var damage := 10

@onready var map: TileMap = $".."
var direction := Vector2i(0, 1)
@onready var map_pos: Vector2i = map.local_to_map(position):
	set(pos):
		map_pos = pos
		position = map.map_to_local(map_pos)

func _ready():
	%AITimer.timeout.connect(ai_step)

func _process(delta):
	%PlayerHazards.add_goal(self, 10)

func ai_step():
	for thing in $CollisionDetector.collisions:
		var thing_dir: Vector2i = $CollisionDetector.collisions[thing]
		if thing is CollisionDetector:
			thing = thing.get_parent()
		if thing.is_queued_for_deletion():
			continue # Skip deleted things, just in case

		if thing is Player:
			_attack_player(thing)
		else:
			continue # idk how to handle this thing, so try a different one

		# We're interacting with a thing, so look at it
		direction = thing_dir

		return # only one action per AI step

	map_pos = $"../EnemyPathfinder".path_next(map_pos)

func _attack_player(player: Player) -> void:
	player.health -= damage
	if player.health > 70 or player.health < 20:
		player.boredom -= 3
