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
			end_game(false)
	elif Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
			
func end_game(has_checkout):
	GameData.game_is_running = false
	GameData.character_frozen = true
	if has_checkout:
		var items_checked_out = $Checkout.get_overlapping_bodies()
		var number_of_items = 0
		for item in items_checked_out:
			if item.get_collision_layer() > 10:
				continue
			number_of_items += 1
		
		$GUI.show_status("Good job. You got %1d items. Press ENTER to retry." % number_of_items)
		pour_items(items_checked_out)
	else:
		$GUI.show_status("Oh no! Checkout has been closed. Press ENTER to retry.")

func pour_items(items):
	for item in items:
		if item.get_collision_layer() > 10:
			continue
		item.visible = false
		
	$EndCamera.current = true
	
	for item in items:
		if item.get_collision_layer() > 10:
			continue
		
		yield(get_tree().create_timer(.2), "timeout")
		item.translation = $EndSpawn.translation
		item.visible = true
		item.apply_torque_impulse(Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)))


func _on_Checkout_body_entered(body):
	if body == $Player:
		end_game(true)
