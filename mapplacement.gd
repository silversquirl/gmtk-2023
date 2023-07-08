extends Node2D

const HEIGHT = 256
const WIDTH = HEIGHT

func tile_size():
	return $TileMap.tile_set.tile_size
func visible_size():
	return Vector2i(WIDTH, HEIGHT) * tile_size()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = -0.5 * visible_size() / scale
	
