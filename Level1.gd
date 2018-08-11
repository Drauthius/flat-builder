extends Node

var Beam = preload("res://Beam.tscn")
var BeamSprite = preload("res://BeamSprite.tscn")

var from = null
var placing = null
var cooldown = false

var beams = []

func _process(delta):
	if placing:
		var mpos = get_viewport().get_mouse_position()
		placing.look_at(mpos)
		var diff = mpos - from #.position
		#placing.get_node("Mid").scale.x = diff.length() / 64.0
		placing.get_node("Sprite").scale.x = diff.length() / 32.0
	if cooldown:
		print("Cool it down")
	cooldown = false

func _unhandled_input(event):
	if event is InputEventMouseButton and placing:
		if placing.get_node("Sprite").scale.x > 0.5:
			var beam = Beam.instance()
			add_child(beam)
			beam.set_position(placing.get_position())
			beam.set_rotation(placing.get_rotation())
			var length = (event.position - from).length()
			beam.get_node("Mid/TextureRect").rect_size.x = length
			beam.get_node("Right").position = Vector2(length, 0)
			beam.get_node("Mid/CollisionShape2D").shape.extents.x = length / 2
			beam.get_node("Mid/CollisionShape2D").position.x = length / 2 - 30
			beam.get_node("Left").connect("clicked", self, "_on_Joint_clicked")
			print("Connected left ", beam.get_node("Left"))
			beam.get_node("Right").connect("clicked", self, "_on_Joint_clicked")
			print("Connected right ", beam.get_node("Right"))
			beams.append(beam)
			print("bye")
			cooldown = true
		remove_child(placing)
		placing = null
		from = null

#func _on_GroundJoint_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton and not placing:
#		print("hello", " ", viewport)
#		from = $GroundJoint
#		placing = BeamSprite.instance()
#		add_child(placing)
#		#placing.get_node("Left").mode = RigidBody2D.MODE_KINEMATIC
#		#placing.get_node("Right").mode = RigidBody2D.MODE_KINEMATIC
#		#placing.get_node("Mid").mode = RigidBody2D.MODE_KINEMATIC
#		#var left = placing.get_node("Left").position
#		placing.set_position(event.position)

func _on_Joint_clicked(joint):
	if not placing and not cooldown:
		print("hello", " ", joint)
		from = joint.get_global_transform().origin
		placing = BeamSprite.instance()
		add_child(placing)
		placing.set_position(from)