extends Container

func _ready():
	set_visible(false)

func _process(_dt):
	if %Player.health <= 0:
		game_over("The player has died")
	if %Player.boredom >= 100:
		game_over("The player got bored and left")

func game_over(message: String) -> void:
	set_visible(true)
	%AITimer.stop()
	$Message.text = message
