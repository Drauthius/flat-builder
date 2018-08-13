extends RigidBody2D

signal destroyed

var Smoke = preload("res://scenes/Smoke.tscn")

var num_speeds = 3
var max_degrees = 45
var max_speed_squared = 1000
var speeds = []

func _ready():
	for i in range(num_speeds):
		speeds.push_back(Vector2(0, 0))

func _integrate_forces(state):
	if mode != MODE_RIGID:
		return
	
	if abs(rotation_degrees) >= max_degrees or abs(rotation_degrees) >= 360 - max_degrees:
		destroy()
	elif abs((linear_velocity - speeds.front()).length_squared()) > max_speed_squared:
		destroy()
	
	speeds.pop_front()
	speeds.push_back(linear_velocity)
	
#	for i in range(state.get_contact_count()):
#		#print(i, ": ", state.get_contact_collider_velocity_at_position(i))
#		if state.get_contact_collider_velocity_at_position(i).length_squared() > 10000:
#			destroy()

func destroy():
	emit_signal("destroyed", self)
	# Add a puff of smoke.
	var smoke = Smoke.instance()
	get_tree().get_root().add_child(smoke)
	smoke.position = get_global_transform().origin
	smoke.emitting = true
	
	queue_free()