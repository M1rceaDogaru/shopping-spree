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
