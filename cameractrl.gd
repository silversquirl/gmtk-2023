extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", fixzoom)
	pass # Replace with function body.
func fixzoom():
	var vp = get_viewport_rect().size
	var minzoom = max(vp.y / HEIGHT, vp.x / WIDTH)
	var newmag = max(zoom.x, minzoom)
	zoom = Vector2(newmag, newmag)
	position = fixpos(position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

const HEIGHT = 256 * 6
const WIDTH = HEIGHT
var dragging_from = null
var prev_pos = null
func fixpos(pos):
	var extents = get_viewport_rect().size * 0.5 / zoom
	return pos.clamp(Vector2(-128 * 6 + extents.x, -128 * 6 + extents.y), Vector2(128 * 6 - extents.x, 128 * 6 - extents.y))
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
