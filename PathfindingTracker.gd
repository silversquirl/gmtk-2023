extends Node

var buffer := PackedInt32Array()
var seeds := Dictionary()
var old_seeds := Dictionary()
@onready var tiles: TileMap = $"../EditableMap"

const directions := [
	Vector2i(0, 1),
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(-1, 0),
]

func _ready():
	buffer.resize(Global.map_size ** 2)
	buffer.fill(-1)

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
		) or not passable(cell.pos):
			continue

		var i := idx(cell.pos)
		if buffer[i] < cell.value:
			buffer[i] = cell.value
			for dir in directions:
				queue.push_back({
					pos = cell.pos + dir,
					value = cell.value - 1
				})

func finish():
	if old_seeds == seeds:
		# Reset seeds
		seeds.clear()
		return

	_rebuild()

	# Reset seeds
	old_seeds = seeds
	seeds = Dictionary()

	$PathfindingDebug.queue_redraw()

func passable(pos: Vector2i) -> bool:
	var data := tiles.get_cell_tile_data(0, pos)
	return data and data.terrain == 0

func goal(obj: Node2D, priority: int):
	var pos := tiles.local_to_map(tiles.to_local(obj.global_position))
	seeds[pos] = max(seeds.get(pos, -1), priority)

func path_next(pos: Vector2i) -> Vector2i:
	var value := 0
	var next := pos
	for dir in directions:
		var val := get_cell(pos + dir)
		if val > value:
			value = val
			next = pos + dir
	return next

func idx(pos: Vector2i) -> int:
	return pos.y * Global.map_size + pos.x

# Get a cell value from the front buffer
func get_cell(pos: Vector2i) -> int:
	return buffer[idx(pos)]
