extends Node

const EditableMap = preload("res://EditableMap.gd")

@export var scale: int = 1

var buffer := PackedInt32Array()
var seeds := Dictionary()
var old_seeds := Dictionary()
var dirty := false
@onready var tiles: EditableMap = %EditableMap

signal rebuild

func _ready():
	buffer.resize(Global.map_size ** 2)
	buffer.fill(-1)
	tiles.map_update.connect(func(): dirty = true)

func _rebuild():
	# Clear the buffer
	buffer.fill(-1)

	var queue := []
	for pos in seeds:
		queue.push_back({
			pos = pos,
			value = seeds[pos],
		})

	while not queue.is_empty():
		var cell = queue.pop_front()
		if (
			cell.pos.x < 0 or cell.pos.y < 0 or
			cell.pos.x >= Global.map_size or cell.pos.y >= Global.map_size
		) or not tiles.passable(cell.pos):
			continue

		var i := _idx(cell.pos)
		if buffer[i] < cell.value:
			buffer[i] = cell.value
			print(cell.pos, cell.value)
			for dir in Global.directions:
				if tiles.can_walk_to(cell.pos, dir):
					queue.push_back({
						pos = cell.pos + dir,
						value = cell.value - 1
					})

func finish():
	if old_seeds == seeds and not dirty:
		# Reset seeds
		seeds.clear()
		return

	_rebuild()

	# Reset seeds
	old_seeds = seeds
	seeds = Dictionary()

	dirty = false
	rebuild.emit()

func add_goal(obj: Node2D, priority: int):
	var pos := tiles.local_to_map(tiles.to_local(obj.global_position))
	seeds[pos] = max(seeds.get(pos, -1), priority)

func _idx(pos: Vector2i) -> int:
	return pos.y * Global.map_size + pos.x

func get_cell(pos: Vector2i) -> int:
	var v := buffer[_idx(pos)]
	if v < 0:
		return v
	return v * scale
