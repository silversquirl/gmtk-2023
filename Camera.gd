extends Camera2D

const zoom_levels = [
	8,
	6,
	4,
	4,
	2,
	2,
	1,
	1,
	pow(0.9, 1),
	pow(0.9, 2),
	pow(0.9, 3),
	pow(0.9, 4),
	pow(0.9, 5),
	pow(0.9, 6),
	pow(0.9, 7),
	pow(0.9, 8),
	pow(0.9, 9),
	pow(0.9, 10),
	pow(0.9, 11),
	pow(0.9, 12),
	pow(0.9, 13),
]
var current_zoom = 3
func _ready():
	get_tree().get_root().connect("size_changed", fixzoom)

func fixzoom():
	var vp = get_viewport_rect().size	
	var visible_world = %EditableMap.visible_size()
	var minzoom = max(vp.y / visible_world.y, vp.x / visible_world.x)
	var newmag = max(zoom_levels[current_zoom], minzoom)
	zoom = Vector2(newmag, newmag)
	position = fixpos(position)
	%EditableMap.texture_filter = TEXTURE_FILTER_NEAREST if newmag >= 1 else TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
var dragging_from = null
var prev_pos = null
func fixpos(pos):
	var extents = get_viewport_rect().size * 0.5 / zoom
	var visible_world = %EditableMap.visible_size()
	return pos.clamp(Vector2(extents.x, extents.y), Vector2(visible_world.x - extents.x, visible_world.y - extents.y))
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && (event.button_index == MOUSE_BUTTON_WHEEL_UP || event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			current_zoom = clamp(current_zoom + (1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1), 0, len(zoom_levels) - 1)
			var prevzoom = zoom.x
			var mouse_delta = (to_local(get_screen_center_position()) - get_local_mouse_position())
			fixzoom()
			position += mouse_delta * ((prevzoom / zoom.x) - 1)

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
