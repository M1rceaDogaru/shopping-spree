extends KinematicBody

onready var camera = $Pivot/Camera
onready var joint = $Pivot/Camera/Hold/PinJoint

var gravity = -30
var max_speed = 8
var mouse_sensitivity = 0.002  # radians/pixel
var pickup_distance = 2

var velocity = Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func get_input():
	var input_dir = Vector3()
	
	# handle exit request
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		
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
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)
		
func move(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed

	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
func attach_to_joint(collider):
	var picked_object = collider.get_path()
	joint.set_node_b(picked_object)
	
func pickup():
	if (Input.is_action_just_pressed("interact")):
		if (joint.get_node_b() != ""):
			joint.set_node_b("")
		else:
			var space_state = get_world().direct_space_state
			var from = camera.global_transform.origin
			var to = from + (camera.global_transform.basis.z * -1 * pickup_distance)
			var result = space_state.intersect_ray(from, to, [self])
			
			if result:
				attach_to_joint(result.collider)

func _physics_process(delta):
	move(delta)
	pickup()
