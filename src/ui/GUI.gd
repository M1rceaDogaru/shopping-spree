extends Control

func on_item_picked_up(value): 
	if value:
		$Pickup.visible = false
		$Drop.visible = true
		$Throw.visible = true
	else:
		$Drop.visible = false
		$Throw.visible = false
		
func on_item_highlighted(value):
	if value:
		$Pickup.visible = true
		$Drop.visible = false
		$Throw.visible = false
	else:
		$Pickup.visible = false
		
func show_status(message):
	$Status.text = message
	$Status.visible = true
	
func hide_status():
	$Status.visible = false
	
func set_time(value):
	$Timer.text = "%1.2f" % value
