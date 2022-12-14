extends KinematicBody

signal item_picked_up(value)
signal item_highlighted(value)

onready var camera = $Pivot/Camera
onready var joint = $Pivot/Camera/Hold/PinJoint

var gravity = -30
var max_speed = 6
var jump_height = 10
var mouse_sensitivity = 0.002  # radians/pixel
var pickup_distance = 3
var throw_force = 800

var velocity = Vector3()
var highlighted: Node = null

func _ready():
	pass

func get_input():
	var input_dir = Vector3()
	
	# handle exit request
	if Input.is_action_just_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
		
	if GameData.character_frozen:
		return input_dir
		
	# desired move in camera direction
	if Input.is_action_pressed("move_forward"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.5, 1.5)
	elif event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func move(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
func attach_to_joint(collider):
	var layer = collider.get_collision_layer()
	if layer > 1:
		# snap object to holding node. Offers better stability but only for small objects
		collider.global_transform.origin = joint.global_transform.origin
		
	# give it a bump to wake rigidbody from sleep
	collider.apply_torque_impulse(Vector3.LEFT * 0.001)
	var picked_object = collider.get_path()
	joint.set_node_b(picked_object)
	emit_signal("item_picked_up", true)
	
func set_highlight(value: bool):
	if highlighted:
		var outline = highlighted.find_node("Outline")
		if outline:
			outline.visible = value
			emit_signal("item_highlighted", value)
			
func get_whatever_i_look_at():
	var space_state = get_world().direct_space_state
	var from = camera.global_transform.origin
	var to = from + (camera.global_transform.basis.z * -1 * pickup_distance)
	return space_state.intersect_ray(from, to, [self], 1)
	
func highlight():
	# no highlight needed if object in hand
	if (joint.get_node_b() != ""):
		return
	
	# TODO: extract this in a function and reuse
	var result = get_whatever_i_look_at()
	
	if result:
		set_highlight(false)
		highlighted = result.collider
		set_highlight(true)
	else:
		set_highlight(false)
	
func pickup():
	if (!Input.is_action_just_pressed("interact")):
		return
	
	if (joint.get_node_b() != ""):
		joint.set_node_b("")
		emit_signal("item_picked_up", false)
	else:
		var result = get_whatever_i_look_at()
		if result:
			attach_to_joint(result.collider)
			$Grab.play()
				
func throw():
	if (!Input.is_action_just_pressed("throw")):
		return
	
	# no object in hand to throw
	if (joint.get_node_b() == ""):
		return
		
	var object_in_hand = get_node(joint.get_node_b())
	joint.set_node_b("")
	object_in_hand.add_force(camera.global_transform.basis.z * -1 * throw_force, Vector3(0, 0, 0))
	$Throw.play()

func jump():
	if GameData.character_frozen:
		return
		
	if (Input.is_action_just_pressed("jump")):
		velocity.y += jump_height

func _physics_process(delta):
	jump()
	move(delta)
	highlight()
	pickup()
	throw()
