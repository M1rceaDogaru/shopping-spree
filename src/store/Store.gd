extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.current_game_duration = GameData.game_duration
	$GUI.set_time(GameData.current_game_duration)
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
	elif Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
			
func end_game():
	GameData.game_is_running = false
	GameData.character_frozen = true
	var items_checked_out = $Checkout.get_overlapping_bodies()
	$GUI.show_status("You're out of time. You got %1d items. Press ENTER to retry." % items_checked_out.size())
	pour_items(items_checked_out)

func pour_items(items):
	for item in items:
		if item == $Player or item == $Floor:
			continue
		item.visible = false
		
	$EndCamera.current = true
	
	for item in items:
		if item == $Player or item == $Floor:
			continue
		
		yield(get_tree().create_timer(.2), "timeout")
		item.translation = $EndSpawn.translation
		item.visible = true
		item.apply_torque_impulse(Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)))
