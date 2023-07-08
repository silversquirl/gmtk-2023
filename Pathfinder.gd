extends Node

const EditableMap = preload("res://EditableMap.gd")

@export var seek: Node
@export var avoid: Node
@onready var tiles: EditableMap = %EditableMap

func path_next(pos: Vector2i) -> Vector2i:
	var value := get_cell(pos)
	var next := []
	# Staying still should be common when there's nothing to path to
	next.resize(10)
	next.fill(pos)

	for dir in Global.directions:
		if not tiles.can_walk_to(pos, dir):
			continue
		var val := get_cell(pos + dir)
		if val > value:
			value = val
			next = [pos + dir]
		elif val == value:
			next.push_back(pos + dir)

	# Occasionally go the wrong way
	if randi_range(0, 4) < 1:
		var dir = _rand_select(Global.directions)
		if tiles.can_walk_to(pos, dir):
			return pos + dir

	return _rand_select(next)

func get_cell(pos: Vector2i) -> int:
	return seek.get_cell(pos) - avoid.get_cell(pos)

func _rand_select(array: Array):
	return array[randi_range(0, len(array) - 1)]
