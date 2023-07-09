extends Node2D

const right = Vector2i(1, 0)
const left = Vector2i(-1, 0)
const down = Vector2i(0, 1)
const up = Vector2i(0, -1)

var collisions := {}

func _physics_process(_dt):
	collisions.clear()
	_add_collisions($Right, right)
	_add_collisions($Left, left)
	_add_collisions($Up, up)
	_add_collisions($Down, down)
func _add_collisions(area: Area2D, dir: Vector2i):
	for thing in area.get_overlapping_areas():
		var parent := thing.get_parent()
		if parent == self: continue
		collisions[parent] = dir
