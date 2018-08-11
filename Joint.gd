extends RigidBody2D

signal clicked

func _on_Joint_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		emit_signal("clicked", self)