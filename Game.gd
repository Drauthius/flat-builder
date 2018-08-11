extends Node

func _ready():
	var beam = $Beam
	beam.get_node("Mid").mode = RigidBody2D.MODE_RIGID
	beam.get_node("Left").mode = RigidBody2D.MODE_RIGID
	beam.get_node("Right").mode = RigidBody2D.MODE_RIGID
	beam.get_node("Mid").set_sleeping(false)
	beam.get_node("Left").set_sleeping(false)
	beam.get_node("Right").set_sleeping(false)
	
	beam = $Beam2
	beam.get_node("Mid").mode = RigidBody2D.MODE_RIGID
	beam.get_node("Left").mode = RigidBody2D.MODE_RIGID
	beam.get_node("Right").mode = RigidBody2D.MODE_RIGID
	beam.get_node("Mid").set_sleeping(false)
	beam.get_node("Left").set_sleeping(false)
	beam.get_node("Right").set_sleeping(false)
		
	beam = $Beam3
	beam.get_node("Mid").mode = RigidBody2D.MODE_RIGID
	beam.get_node("Left").mode = RigidBody2D.MODE_RIGID
	beam.get_node("Right").mode = RigidBody2D.MODE_RIGID
	beam.get_node("Mid").set_sleeping(false)
	beam.get_node("Left").set_sleeping(false)
	beam.get_node("Right").set_sleeping(false)