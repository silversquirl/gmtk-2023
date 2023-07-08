extends Node2D

@onready var path_dbg = $"/root/root/PathfindingDebug"

func _ready():
	path_dbg.draw.connect(queue_redraw)

func _draw():
	match path_dbg.mode:
		path_dbg.Mode.PLAYER:
			draw_rect(Rect2(0, 0, 10, 10), Color(0, 1, 0))
		path_dbg.Mode.ENEMY:
			draw_rect(Rect2(0, 0, 10, 10), Color(1, 0, 0))
