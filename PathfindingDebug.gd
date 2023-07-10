extends Node2D

enum Mode { PLAYER, ENEMY }
var mode: Mode = -1
@onready var tiles := %EditableMap

func _ready():
	switch_mode(Mode.PLAYER)

func _input(event: InputEvent):
	if not is_visible():
		return
	if event is InputEventKey and event.pressed:
		match event.key_label:
			KEY_P:
				match mode:
					Mode.PLAYER: switch_mode(Mode.ENEMY)
					Mode.ENEMY: switch_mode(Mode.PLAYER)

func switch_mode(new_mode: Mode):
	match mode:
		Mode.PLAYER:
			%PlayerGoals.rebuild.disconnect(queue_redraw)
			%PlayerHazards.rebuild.disconnect(queue_redraw)
		Mode.ENEMY:
			%EnemyGoals.rebuild.disconnect(queue_redraw)

	mode = new_mode

	match mode:
		Mode.PLAYER:
			%PlayerGoals.rebuild.connect(queue_redraw)
			%PlayerHazards.rebuild.connect(queue_redraw)
		Mode.ENEMY:
			%EnemyGoals.rebuild.connect(queue_redraw)

	queue_redraw()

func _draw() -> void:
	for x in range(Global.map_size):
		for y in range(Global.map_size):
			var pos := Vector2i(x, y)
			match mode:
				Mode.PLAYER:
					_draw_cell(pos, %PlayerGoals, Color(0, 1, 0), Vector2(0, 10))
					_draw_cell(pos, %PlayerHazards, Color(1, 0, 0), Vector2(0, 0))
				Mode.ENEMY:
					_draw_cell(pos, %EnemyGoals, Color(0, 1, 0), Vector2(0, 5))

func _draw_cell(pos: Vector2i, tracker, color: Color, offset: Vector2) -> void:
	var val: int = tracker.get_cell(pos)
	if val == -1: return

	var scene_pos: Vector2 = tiles.map_to_local(pos) + tiles.global_position + offset
	scene_pos += Vector2(tiles.tile_set.tile_size) * Vector2(-0.5, 0)
	var font := get_window().get_theme_default_font()
	draw_string(
		font, scene_pos, str(val),
		HORIZONTAL_ALIGNMENT_CENTER, tiles.tile_set.tile_size.x, 12, color,
	)
