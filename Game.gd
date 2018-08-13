extends Node

var Apartment1x1 = preload("res://scenes/Apartment1x1.tscn")
var Apartment2x1 = preload("res://scenes/Apartment2x1.tscn")
var Apartment1x2 = preload("res://scenes/Apartment1x2.tscn")
var Apartment2x2 = preload("res://scenes/Apartment2x2.tscn")
var Beam = preload("res://scenes/Beam.tscn")
var BeamSprite = preload("res://scenes/BeamSprite.tscn")
var Camera = preload("res://scenes/Camera.tscn")
var CostText = preload("res://scenes/CostText.tscn")
onready var SoundService = $"/root/SoundService"

export(int, 1000000) var money
export(int, 100) var apartment_goal_1
export(int, 100) var apartment_goal_2
export(int, 100) var apartment_goal_3
export(int, 100) var apartment_max_1
export(int, 100) var apartment_max_2
export(int, 100) var apartment_max_3

var num_apts = { 1: 0, 2: 0, 3: 0 }

var min_beam_length = 16
var max_beam_length = 128
var min_beam_cost = 25
var max_beam_cost = 100
var max_joint_separation = 2.0
var max_movement_threshold = 1.0
var play_time_wait = 3.0

var from = null
var placing = null
var cost_text = null

var start_time
var camera
var beams = []
var joints = []
var breakable_joints = []
var apartments = []

enum MODES {
	BEAM_MODE,
	APARTMENT_MODE,
	PHYSICS_MODE
}
var current_mode = MODES.BEAM_MODE

func _ready():
	SoundService.stop_all_music()
	SoundService.basic_music_loop01()
	
	camera = Camera.instance()
	add_child(camera)
	
	# Add the ground joints that are available in the level (identified as RigidBody2D).
	for node in get_children():
		if node is RigidBody2D:
			joints.append(node)
			# Connect the click event for the joint
			node.connect("clicked", self, "_on_Joint_clicked")
	
	$GUI.set_build_mode()
	$GUI.set_money(money)
	$GUI.set_objective(apartment_goal_1, apartment_goal_2, apartment_goal_3)
	$GUI.set_maximum(apartment_max_1, apartment_max_2, apartment_max_3)
	# Connect GUI signals
	# (Done here and not in the editor to avoid the necessary set-up for each new level/scene.)
	$GUI.connect("start_game", self, "play")
	$GUI.connect("place_apartment", self, "instantiate_apartment")

func _process(delta):
	if current_mode != MODES.PHYSICS_MODE:
		if placing and current_mode == MODES.BEAM_MODE:
			_update_placing_beam()
		if placing and current_mode == MODES.APARTMENT_MODE:
			_update_placing_apartment()
		
		if Input.is_action_just_pressed("ui_accept"):
			play()
		elif Input.is_action_just_pressed("ui_cancel"):
			_clear_placing(true)
		else:
			var rooms = 0
			if Input.is_action_just_pressed("apt_1") and num_apts[1] < apartment_max_1:
				rooms = 1
			elif Input.is_action_just_pressed("apt_2") and num_apts[2] < apartment_max_2:
				rooms = 2
			elif Input.is_action_just_pressed("apt_3") and num_apts[3] < apartment_max_3:
				rooms = 3
				
			if rooms > 0:
				instantiate_apartment(rooms)
	else:
		var joints_to_be_removed = []
		for joint in breakable_joints:
			var r1 = get_node(joint.node_a).get_global_transform().origin
			var r2 = get_node(joint.node_b).get_global_transform().origin
			var diff = (r1 - r2).length()
			if diff > max_joint_separation/2.0:
				var x = -1.0  + diff*2.0/max_joint_separation
	#			var y = lerp(max_joint_separation/2.0, max_joint_separation, x)
				get_node(joint.node_a).modulate = Color(1.0, 1.0-x, 1.0-x)
				get_node(joint.node_b).modulate = Color(1.0, 1.0-x, 1.0-x)
	#			print(get_node(joint.node_a).modulate)
			else:
				get_node(joint.node_a).modulate = Color(1.0, 1.0, 1.0)
				get_node(joint.node_b).modulate = Color(1.0, 1.0, 1.0)
			if diff > max_joint_separation:
				joints_to_be_removed.append(joint)
		for joint in joints_to_be_removed:
			SoundService.beam_joint_destruction()
			breakable_joints.erase(joint)
			joint.queue_free()
		
		if start_time > play_time_wait: # Need to wait at least this time for things to start moving.
			for apartment in apartments:
				if apartment.linear_velocity.length_squared() > max_movement_threshold:
					return
				
			pause()
			if num_apts[1] >= apartment_goal_1 and num_apts[2] >= apartment_goal_2 and num_apts[3] >= apartment_goal_3:
				$GUI.set_winning_mode()
		else:
			start_time += delta

func instantiate_apartment(rooms):
	if current_mode == MODES.PHYSICS_MODE:
		return
	
	_clear_placing(true)
	current_mode = MODES.APARTMENT_MODE
	
	var type = null
	match rooms:
		1:
			type = Apartment1x1
		2:
			if randi() % 2 == 0:
				type = Apartment2x1
			else:
				type = Apartment1x2
		3:
			type = Apartment2x2
	
	assert(type != null)
	placing = type.instance()
	add_child(placing)
	placing.set_position(get_viewport().get_mouse_position())

# Start physics.
func play():
#	SoundService.physics_pause()
	start_time = 0.0
	_clear_placing(true)
	current_mode = MODES.PHYSICS_MODE
	$GUI.set_simulation_mode()
	for beam in beams:
		beam.get_node("Mid").mode = RigidBody2D.MODE_RIGID
		beam.get_node("Left").mode = RigidBody2D.MODE_RIGID
		beam.get_node("Right").mode = RigidBody2D.MODE_RIGID
		beam.get_node("Mid").set_sleeping(false)
		beam.get_node("Left").set_sleeping(false)
		beam.get_node("Right").set_sleeping(false)
	
	for apartment in apartments:
		apartment.mode = RigidBody2D.MODE_RIGID
		apartment.set_sleeping(false)

# Stop physics
func pause():
#	SoundService.physics_pause()
	start_time = 0.0
	_clear_placing(true)
	$GUI.set_build_mode()
	for beam in beams:
		beam.get_node("Mid").mode = RigidBody2D.MODE_KINEMATIC
		beam.get_node("Left").mode = RigidBody2D.MODE_KINEMATIC
		beam.get_node("Right").mode = RigidBody2D.MODE_KINEMATIC
		beam.get_node("Mid").set_sleeping(true)
		beam.get_node("Left").set_sleeping(true)
		beam.get_node("Right").set_sleeping(true)
	
	for apartment in apartments:
		apartment.mode = RigidBody2D.MODE_KINEMATIC
		apartment.set_sleeping(true)

# Stretch and rotate the beam sprite that is currently being placed.
# Force will ignore (or exagerate) the maximum beam length, to avoid connections that are juuuust short.
func _update_placing_beam(position = null, force = false):
	if not position:
		position = get_viewport().get_mouse_position()
	placing.look_at(position)
	var length = min(max_beam_length if not force else max_beam_length * 100, (position - from.position).length())
	placing.get_node("Sprite").rect_size.x = length
	
	var cost = 0
	if length >= min_beam_length:
		cost = (length - min_beam_length) / (max_beam_length - min_beam_length) * (max_beam_cost - min_beam_cost) + min_beam_cost
	
	cost_text.set_cost(round(cost), cost > money)
	$GUI.set_insufficient(cost > money)
	
	return placing.to_global(Vector2(length, 0))

# Just changing the position of the apartment to be placed
func _update_placing_apartment():
	placing.set_position(get_viewport().get_mouse_position())

# Called when clicked on things that aren't a joint.
# This function recieves the input event before the joint for some reason (when placing), so just handle it here I guess.
func _unhandled_input(event):
	if current_mode == MODES.PHYSICS_MODE or not placing or not event is InputEventMouseButton or not event.button_index == BUTTON_LEFT or event.pressed:
		return
		
	#handling beams
	if current_mode == MODES.BEAM_MODE:
		#print("unhandled input")
		get_tree().set_input_as_handled() # Marked as handled.
		
		# Get the position of the beam's end.
		var position = _update_placing_beam(event.position)
		
		# Create a shape + transform for checking if a click connects to an existing joint.
		var shape = CircleShape2D.new()
		shape.radius = 10
		var transform = Transform2D(0.0, position)
		
		for joint in joints:
			if joint.get_node("CollisionShape2D").shape.collide(joint.get_global_transform(), shape, transform):
				# Update the placing node, so that _place_beam puts the end at the right place.
				position = _update_placing_beam(joint.get_global_transform().origin, true)
				
				_place_beam(position, joint)
				return
				
		_place_beam(position)
	#handling apartments
	elif current_mode == MODES.APARTMENT_MODE:
		get_tree().set_input_as_handled() # Marked as handled.
		
		# Update, in case it isn't exactly on the mouse.
		_update_placing_apartment()
		
		_place_apartment(event.position)

# Called when a joint (ground or from a beam) is clicked.
func _on_Joint_clicked(joint):
	if current_mode != MODES.BEAM_MODE:
		return
	
	var position = joint.get_global_transform().origin
	
	if not placing:
		#print("attaching to ", joint)
		from = { "joint": joint, "position": position }
		placing = BeamSprite.instance()
		add_child(placing)
		placing.position = from.position
		cost_text = CostText.instance()
		add_child(cost_text)
		cost_text.position = from.position - Vector2(20, 40)
		SoundService.beam_placement_selection()
	#else:
		# The above _unhandled_event gets the event before the click event on the joint.

# Called when trying to place a beam.
func _place_beam(position, other_joint = null):
	# How much softness to allow for the pin joints.
	# This needs to be greater than zero, to avoid having too rigid structures that start to vibrate.
	var slackness = 0.5
	
	# Minimum length requirement for placing beam.
	if placing.get_node("Sprite").rect_size.x >= min_beam_length and cost_text.cost <= money:
		# Reduce the amount of money
		money -= cost_text.cost
		$GUI.set_money(money)
		
		# Create a new beam
		var beam = Beam.instance()
		beam.set_position(placing.get_position())
		beam.set_rotation(placing.get_rotation())
		add_child(beam)
		
		# Set the length of the beam (texture sprite) and the position of the right joint.
		var length = (position - from.position).length()
		beam.get_node("Mid/TextureRect").rect_size.x = length
		beam.get_node("Right").position = Vector2(length, 0)
		# The mass has to be updated to correspond with the length
		beam.get_node("Mid").mass = length / 320.0
		
		# This is utter shit. The joint connecting the right ball to the beam has to be added here, or it will snap back to the original position
		# once the mode is changed to rigid (if it was added in the editor). The left joint is handled the same way for consistency.
		yield(get_tree(), "idle_frame") # Wait a frame, because why not (probably needed for the rigid body to "update").
		var left_joint = PinJoint2D.new()
		left_joint.softness = slackness
		left_joint.position = beam.get_node("Left").position - Vector2(30, 0)
		left_joint.node_a = beam.get_node("Mid").get_path()
		left_joint.node_b = beam.get_node("Left").get_path()
		beam.get_node("Mid").add_child(left_joint)
		
		var right_joint = PinJoint2D.new()
		right_joint.softness = slackness
		right_joint.position = beam.get_node("Right").position - Vector2(30, 0)
		right_joint.node_a = beam.get_node("Mid").get_path()
		right_joint.node_b = beam.get_node("Right").get_path()
		beam.get_node("Mid").add_child(right_joint)
		
		# Recreate the collision shape, since it is shared among all beams, but they need to be unique (since the length might be different).
		beam.get_node("Mid/CollisionShape2D").set_shape(beam.get_node("Mid/CollisionShape2D").get_shape().duplicate())
		# Set the length of the collision shape (minus a small offset)
		beam.get_node("Mid/CollisionShape2D").shape.extents.x = length / 2 - 10
		# Set the position of the collision shape (needs to be in the middle of the beam)
		beam.get_node("Mid/CollisionShape2D").position.x = length / 2 - 30
		
		# Connect the click events for the left and right joints
		beam.get_node("Left").connect("clicked", self, "_on_Joint_clicked")
		beam.get_node("Right").connect("clicked", self, "_on_Joint_clicked")
		
		# Add the beam and joints to the lists
		beams.append(beam)
		joints.append(beam.get_node("Left"))
		joints.append(beam.get_node("Right"))
		
		# Add the pin joints connecting the beam with the joints it was placed upon.
		# Have to yield here, or the thing goes haywire once the body is set to rigid.
		yield(get_tree(), "idle_frame")
		var joint = PinJoint2D.new()
		beam.get_node("Mid").add_child(joint)
		joint.softness = slackness
		joint.position = left_joint.position
		joint.node_a = from.joint.get_path()
		joint.node_b = beam.get_node("Left").get_path()
		breakable_joints.append(joint)
		
		# Add a pin joint for the right joint if it is connected to anything.
		if other_joint:
			joint = PinJoint2D.new()
			beam.get_node("Mid").add_child(joint)
			joint.softness = slackness
			joint.position = right_joint.position
			joint.node_a = other_joint.get_path()
			joint.node_b = beam.get_node("Right").get_path()
			breakable_joints.append(joint)
			SoundService.beam_placement_finalise()
		else:
			SoundService.beam_placement_selection()

	# Clear the placing stuff.
	_clear_placing(true)
	# Reset GUI
	$GUI.set_insufficient(false)

func _place_apartment(position):
	placing.set_position(position)
	placing.connect("destroyed", self, "_on_Apartment_destroyed")
	var num_rooms = 0
	if "1x1" in placing.get_name():
		num_rooms = 1
	elif "1x2" in placing.get_name() or "2x1" in placing.get_name():
		num_rooms = 2
	elif "2x2" in placing.get_name():
		num_rooms = 3
	
	assert(num_rooms > 0)
	num_apts[num_rooms] += 1
	$GUI.add_apartment(num_rooms)
	
	apartments.append(placing)
	_clear_placing(false)
	
	#camera.shake(Vector2(0.5, 0.5), 0.1)

func _on_Apartment_destroyed(object):
	SoundService.block_destruction()
	var num_rooms = 0
	if "1x1" in object.get_name():
		num_rooms = 1
	elif "1x2" in object.get_name() or "2x1" in object.get_name():
		num_rooms = 2
	elif "2x2" in object.get_name():
		num_rooms = 3
	
	assert(num_rooms > 0)
	num_apts[num_rooms] -= 1
	$GUI.remove_apartment(num_rooms)	
	apartments.erase(object)
	
	camera.shake(Vector2(5.0, 5.0), 0.2)

func _clear_placing(free):
	# Reset the current mode to the default.
	current_mode = MODES.BEAM_MODE
	
	if placing and free:
		placing.queue_free()
	if cost_text:
		cost_text.queue_free()
	cost_text = null
	placing = null
	from = null