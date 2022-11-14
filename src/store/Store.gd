extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.current_game_duration = GameData.game_duration
	$GUI.show_status("GET READY...")
	yield(get_tree().create_timer(2), "timeout")
	$GUI.show_status("GRAB! GRAB! GRAB!")
	GameData.character_frozen = false
	GameData.game_is_running = true
	yield(get_tree().create_timer(2), "timeout")
	$GUI.hide_status()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameData.game_is_running:
		GameData.current_game_duration -= delta
		$GUI.set_time(GameData.current_game_duration)
		if GameData.current_game_duration <= 0.0:
			end_game()
			
func end_game():
	GameData.game_is_running = false
	GameData.character_frozen = true
	$GUI.show_status("You're out of time. Come back tomorrow.")
