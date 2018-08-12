extends Node

var Beam = preload("res://Beam.tscn")
var BeamSprite = preload("res://BeamSprite.tscn")

var from = null
var placing = null

var playing = false
var beams = []
var joints = []

func _ready():
	joints.append($GroundJoint)
	joints.append($GroundJoint2)

func _process(delta):
	if placing:
		var mpos = get_viewport().get_mouse_position()
		placing.look_at(mpos)
		var diff = mpos - from.position
		placing.get_node("Sprite").rect_size.x = diff.length()
	
	if not playing and Input.is_action_just_pressed("ui_accept"):
		print("PHYSICS!")
		play()

func play():
	playing = true
	
	#var joint = $PinJoint2D
	#joint.node_a = NodePath("../GroundJoint")
	#joint.node_b = NodePath("../Beam/Left")
	
	for beam in beams:
		beam.get_node("Mid").mode = RigidBody2D.MODE_RIGID
		beam.get_node("Left").mode = RigidBody2D.MODE_RIGID
		beam.get_node("Right").mode = RigidBody2D.MODE_RIGID
		beam.get_node("Mid").set_sleeping(false)
		beam.get_node("Left").set_sleeping(false)
		beam.get_node("Right").set_sleeping(false)

func _unhandled_input(event):
	if playing:
		return
		
	if event is InputEventMouseButton and placing and event.button_index == BUTTON_LEFT and not event.pressed:
		#print("unhandled event")
		get_tree().set_input_as_handled()
		
		# This function recieves the input event before the joint for some reason, so just handle it here I guess.
		var shape = CircleShape2D.new()
		shape.radius = 10
		var transform = Transform2D(0.0, event.position)
		for joint in joints:
			if joint.get_node("CollisionShape2D").shape.collide(joint.get_global_transform(), shape, transform):
				#print("Join joints!")
				# Update the placing node, so that _place_beam puts the end at the right place.
				var position = joint.get_global_transform().origin #+ Vector2(100, 100)
				placing.look_at(position)
				placing.get_node("Sprite").rect_size.x = (position - from.position).length()
				_place_beam(position, joint)
				return
		_place_beam(event.position)

func _on_Joint_clicked(joint):
	if playing:
		return
	
	var position = joint.get_global_transform().origin
	#print("pos ", position)
	
	if not placing:
		#print("attaching to ", joint)
		from = { "joint": joint, "position": position }
		placing = BeamSprite.instance()
		add_child(placing)
		placing.set_position(from.position)
	#else:
		#print("This shouldn't trigger")
		
#		print("re-using ", joint)
#		# Update the placing node, so that _place_beam puts the end at the right place.
#		placing.look_at(position)
#		position += Vector2(100, 100)
#		placing.get_node("Sprite").scale.x = (position - from).length() / 32.0
#		placing.queue_free()
#		placing = null
#		from = null
#		#_place_beam(position)

func _place_beam(position, other_joint = null):
	var slackness = 1
	
	if placing.get_node("Sprite").rect_size.x > 16:
		var beam = Beam.instance()
		beam.set_position(placing.get_position())
		beam.set_rotation(placing.get_rotation())
		add_child(beam)
		
		var length = (position - from.position).length()
		beam.get_node("Mid/TextureRect").rect_size.x = length
		beam.get_node("Right").position = Vector2(length, 0)
		
		# This is utter shit. The joint connecting the right ball to the beam has to be added here, or it will snap back to the original position
		# once the mode is changed to rigid.
		yield(get_tree(), "idle_frame")
		var meh1 = PinJoint2D.new()
		meh1.softness = slackness
		meh1.position = beam.get_node("Left").position - Vector2(30, 0)
		#meh.position = Vector2(-30, 0)
		meh1.node_a = beam.get_node("Mid").get_path()
		meh1.node_b = beam.get_node("Left").get_path()
		beam.get_node("Mid").add_child(meh1)
		
		var meh2 = PinJoint2D.new()
		meh2.softness = slackness
		meh2.position = beam.get_node("Right").position - Vector2(30, 0)
		#meh.position = Vector2(-30, 0)
		meh2.node_a = beam.get_node("Mid").get_path()
		meh2.node_b = beam.get_node("Right").get_path()
		beam.get_node("Mid").add_child(meh2)
		#beam.remove_child(beam.get_node("Mid/PinJoint2D2"))
		#beam.get_node("Mid/PinJoint2D2").position = Vector2(length, 0)
		#beam.get_node("Right/CollisionShape2D").position = Vector2(0, 0) # Vector2(length - 60, 0)
		#beam.get_node("Right/CollisionShape2D").position = Vector2(length, 0)
		#var meh3 = RectangleShape2D.new()
		#beam.get_node("Mid/CollisionShape2D").instance()
		beam.get_node("Mid/CollisionShape2D").set_shape(beam.get_node("Mid/CollisionShape2D").get_shape().duplicate(true))
		beam.get_node("Mid/CollisionShape2D").shape.extents.x = length / 2 - 10
		beam.get_node("Mid/CollisionShape2D").position.x = length / 2 - 30
		beam.get_node("Left").connect("clicked", self, "_on_Joint_clicked")
		beam.get_node("Right").connect("clicked", self, "_on_Joint_clicked")
		beams.append(beam)
		joints.append(beam.get_node("Left"))
		joints.append(beam.get_node("Right"))
		
		beam.get_node("Mid").mass = length / 320.0
		print("New mass ", beam.get_node("Mid").mass)
		
		# Have to yield here, or the thing goes haywire once the body is set to
		# rigid.
		yield(get_tree(), "idle_frame")
		var joint = PinJoint2D.new()
		joint.softness = slackness
		#joint.position = from.position
		joint.position = meh1.position
		#joint.position = beam.get_node("Mid").get_transform().xform_inv(from.position)
		#joint.position = $GroundJoint.position
		beam.get_node("Mid").add_child(joint)
		#add_child(joint)
		#print($GroundJoint)
		#print($GroundJoint.get_path())
		#print(joint.position)
		#print(from.joint.get_name())
		#print(from.joint.get_path())
		#print(beam.get_node("Left").get_path())
		joint.node_a = from.joint.get_path()
		joint.node_b = beam.get_node("Left").get_path()
		#joint.softness = 0
		#joint.bias = 0
		#joint.disable_collision = true
		#joint.node_b = NodePath("../GroundJoint")
		#joint.node_a = NodePath("../Beam/Left")
		
		#var joint = $PinJoint2D
		#joint.node_a = NodePath("../GroundJoint")
		#joint.node_b = NodePath("../Beam/Left")

		if other_joint:
			joint = PinJoint2D.new()
			joint.softness = slackness
			joint.position = meh2.position
			#joint.position = other_joint.get_global_transform().origin
			#joint.position = beam.get_transform().xform_inv(other_joint.get_global_transform().origin)
			joint.node_a = other_joint.get_path()
			joint.node_b = beam.get_node("Right").get_path()
			#add_child(joint)
			#beam.add_child(joint)
			beam.get_node("Mid").add_child(joint)
		#print("bye")
	placing.queue_free()
	placing = null
	from = null
