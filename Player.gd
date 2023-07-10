extends AnimatedSprite2D

const CollisionDetector = preload("res://CollisionDetector.gd")
const Bot = preload("res://Bot.gd")
const Gold = preload("res://Gold.gd")
const Chest = preload("res://Chest.gd")

var gold := 0

var weapon:
	get:
		return %StrengthMeter.value
	set(value):
		%StrengthMeter.value = value

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

	if lerp > 0:
		lerp = clampf(lerp - dt / %AITimer.wait_time, 0.0, 1.0)
		play("walk" + _anim())
	else:
		play("idle" + _anim())

	%EnemyGoals.add_goal(self, 8)

	%PlayerGoals.finish()
	%PlayerHazards.finish()
	%EnemyGoals.finish()

func _anim() -> String:
	match direction:
		Vector2i(0, 1):
			if weapon > 0:
				return "_down_sword"
			else:
				return "_down"
		Vector2i(0, -1):
			return "_up"
		Vector2i(1, 0):
			return "_left"
		Vector2i(-1, 0):
			if weapon > 0:
				return "_left_sword"
			else:
				return "_left"
	return "oopsie"

func ai_step():
	boredom += 1
	health += 2

	for thing in $CollisionDetector.collisions:
		var thing_dir: Vector2i = $CollisionDetector.collisions[thing]
		if thing is CollisionDetector:
			thing = thing.get_parent()
		if thing.is_queued_for_deletion():
			continue # Skip deleted things, just in case

		if thing is Gold:
			_pick_up_gold(thing)
		elif thing is Chest:
			_pick_up_weapon(thing)
		elif thing is Bot and weapon > 0:
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

func _pick_up_weapon(chest: Chest) -> void:
	weapon = chest.weapon_strength
	boredom = 0
	health = 100
	chest.queue_free()

func _attack_enemy(enemy: Bot) -> void:
	enemy.health -= weapon
	if enemy.health <= 0:
		enemy.queue_free()
		%GameOverScreen.recheck_enemies = true
