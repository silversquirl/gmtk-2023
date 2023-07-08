extends Camera2D

func _ready():
	get_tree().get_root().connect("size_changed", fixzoom)

func fixzoom():
	var vp = get_viewport_rect().size
	var visible_world = $"../EditableMap".visible_size()
	var minzoom = max(vp.y / visible_world.y, vp.x / visible_world.x)
	var newmag = max(zoom.x, minzoom)
	zoom = Vector2(newmag, newmag)
	position = fixpos(position)

var dragging_from = null
var prev_pos = null
func fixpos(pos):
	var extents = get_viewport_rect().size * 0.5 / zoom
	var visible_world = $"../EditableMap".visible_size()
	return pos.clamp(Vector2(extents.x, extents.y), Vector2(visible_world.x - extents.x, visible_world.y - extents.y))
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP && event.pressed:
			var newmag = min(zoom.y * 1.1, 5)
			zoom = Vector2(newmag, newmag)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && event.pressed:
			var newmag = zoom.y / 1.1
			zoom = Vector2(newmag, newmag)
			fixzoom()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				dragging_from = event.position
				prev_pos = position
			else:
				dragging_from = null
				prev_pos = null
	if event is InputEventMouseMotion:
		if dragging_from != null:
			position = fixpos(prev_pos + (dragging_from - event.position) / zoom)
