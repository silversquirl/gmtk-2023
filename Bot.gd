extends AnimatedSprite2D

const CollisionDetector = preload("res://CollisionDetector.gd")
const Player = preload("res://Player.gd")

@export var health := 20
@export var damage := 10

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

	scale.x = -1 if direction == Vector2i(1, 0) else 1
	match direction:
		Vector2i(0, 1):
			play("walk_down")
		Vector2i(0, -1):
			play("walk_up")
		Vector2i(1, 0), Vector2i(-1, 0):
			play("walk_left")

	if lerp > 0:
		lerp = clampf(lerp - dt / %AITimer.wait_time, 0.0, 1.0)
	else:
		stop()

	%PlayerHazards.add_goal(self, 10)

func ai_step():
	var block_direction := {}
	for thing in $CollisionDetector.collisions:
		var thing_dir: Vector2i = $CollisionDetector.collisions[thing]
		if thing is CollisionDetector:
			thing = thing.get_parent()
		if thing.is_queued_for_deletion():
			continue # Skip deleted things, just in case

		if thing is Player:
			_attack_player(thing)
		else:
			block_direction[thing_dir] = true
			continue # idk how to handle this thing, so try a different one

		# We're interacting with a thing, so look at it
		direction = thing_dir

		return # only one action per AI step

	var next_pos: Vector2i = $"../EnemyPathfinder".path_next(map_pos)
	if map_pos - next_pos not in block_direction:
		map_pos = next_pos

func _attack_player(player: Player) -> void:
	player.health -= damage
	player.boredom -= 3
