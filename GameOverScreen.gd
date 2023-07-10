extends Node2D

var recheck_enemies := true

func _ready():
	$Violent.set_visible(false)
	$Bored.set_visible(false)
	$Wholesome.set_visible(false)
	$Button.set_visible(false)
	$Button.pressed.connect(_restart_game)

func _process(_dt):
	if %Player.health <= 0:
		game_over($Violent)
	if %Player.boredom >= 100:
		game_over($Bored)
	if recheck_enemies:
		recheck_enemies = false
		if len(%EditableMap.find_children("Bot*")) == 0:
			game_over($Wholesome)

func game_over(message: Sprite2D) -> void:
	message.set_visible(true)
	$Button.set_visible(true)
	%AITimer.stop()

func _restart_game() -> void:
	get_tree().reload_current_scene()
