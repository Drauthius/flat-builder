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

func _process(delta):
	if placing:
		var mpos = get_viewport().get_mouse_position()
		placing.look_at(mpos)
		var diff = mpos - from.position
		placing.get_node("Sprite").rect_size.x = diff.length()
	
	if Input.is_action_just_pressed("ui_accept"):
		print("PHYSICS!")
		play()

func play():
	playing = true
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
		shape.radius = 5
		var transform = Transform2D(0.0, event.position)
		for joint in joints:
			if joint.get_node("CollisionShape2D").shape.collide(joint.get_global_transform(), shape, transform):
				#print("Join joints!")
				# Update the placing node, so that _place_beam puts the end at the right place.
				var position = joint.get_global_transform().origin #+ Vector2(100, 100)
				placing.look_at(position)
				placing.get_node("Sprite").rect_size.x = (position - from.position).length()
				_place_beam(position)
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

func _place_beam(position):
	if placing.get_node("Sprite").rect_size.x > 16:
		var beam = Beam.instance()
		add_child(beam)
		beam.set_position(placing.get_position())
		beam.set_rotation(placing.get_rotation())
		var length = (position - from.position).length()
		beam.get_node("Mid/TextureRect").rect_size.x = length
		beam.get_node("Right").position = Vector2(length, 0)
		beam.get_node("Mid/CollisionShape2D").shape.extents.x = length / 2
		beam.get_node("Mid/CollisionShape2D").position.x = length / 2 - 30
		beam.get_node("Left").connect("clicked", self, "_on_Joint_clicked")
		beam.get_node("Right").connect("clicked", self, "_on_Joint_clicked")
		beams.append(beam)
		joints.append(beam.get_node("Left"))
		joints.append(beam.get_node("Right"))
		
		var joint = PinJoint2D.new()
		joint.position = from.position
		joint.softness = 0
		joint.node_a = from.joint.get_path()
		joint.node_b = beam.get_node("Left").get_path()
		add_child(joint)
		#print("bye")
	placing.queue_free()
	placing = null
	from = null