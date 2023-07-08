# Contains global constants and options for the whole game

extends Node

const map_size = 256

func _ready():
	randomize()

const directions := [
	Vector2i(0, 1),
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(-1, 0),
]
