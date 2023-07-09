extends AnimatedSprite2D

const CollisionDetector = preload("res://CollisionDetector.gd")
const Bot = preload("res://Bot.gd")
const Gold = preload("res://Gold.gd")

var weapon := 0
var gold := 0

var boredom:
	get:
		return %BoredomMeter.value
	set(value):
		%BoredomMeter.value = value

var health:
	get:
		return %HealthMeter.value
	set(value):
		%HealthMeter.value = value

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
			if weapon > 0:
				play("walk_down_sword")
			else:
				play("walk_down")
		Vector2i(0, -1):
			play("walk_up")
		Vector2i(1, 0), Vector2i(-1, 0):
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
	boredom += 1

	for thing in $CollisionDetector.collisions:
		var thing_dir: Vector2i = $CollisionDetector.collisions[thing]
		if thing is CollisionDetector:
			thing = thing.get_parent()
		if thing.is_queued_for_deletion():
			continue # Skip deleted things, just in case

		if thing is Gold:
			_pick_up_gold(thing)
		elif thing is Bot:
			_attack_enemy(thing)
		else:
			continue # idk how to handle this thing, so try a different one

		# We're interacting with a thing, so look at it
		direction = thing_dir

		return # only one action per AI step

	map_pos = $Pathfinder.path_next(map_pos)

func _pick_up_gold(entity: Gold) -> void:
	# Pick up gold
	entity.queue_free()
	gold += 1

	# Alter boredom
	boredom -= 15 - gold

func _attack_enemy(enemy: Bot) -> void:
	enemy.health -= weapon
