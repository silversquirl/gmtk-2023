extends Node

var buffers := [PackedInt32Array(), PackedInt32Array()]
var back := 0
@onready var tiles: TileMap = $"../TileMap"

const directions := [
	Vector2i(0, 1),
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(-1, 0),
]

func _ready():
	for n in range(len(buffers)):
		buffers[n].resize(Global.map_size ** 2)
		buffers[n].fill(-1)
		
	finish()

func finish():
	# Propagate heatmap
	for x in range(Global.map_size):
		for y in range(Global.map_size):
			var pos := Vector2i(x, y)
			if not passable(pos):
				continue

			var value := 0
			for dir in directions:
				var offset_pos: Vector2i = pos + dir
				if (
					offset_pos.x < 0 or offset_pos.y < 0 or
					offset_pos.x >= Global.map_size or offset_pos.y >= Global.map_size
				):
					continue

				var val: int = buffers[back][idx(offset_pos)]
				value = min(value, val)

			value = max(value, 0)
			bump_cell(pos, value)

	# Flip buffers
	back = 1 - back
	# Clear new back buffer
	buffers[back].fill(-1)

func passable(pos: Vector2i) -> bool:
	var data := tiles.get_cell_tile_data(0, pos)
	return data and data.terrain == 0

func goal(obj: Node2D, priority: int):
	var pos := tiles.local_to_map(obj.position)
	bump_cell(pos, priority)

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
# Bump a cell in the back buffer
func bump_cell(pos: Vector2i, value: int):
	var i := idx(pos)
	buffers[back][i] = max(value, buffers[back][i])

# Get a cell value from the front buffer
func get_cell(pos: Vector2i) -> int:
	return buffers[1 - back][idx(pos)]
