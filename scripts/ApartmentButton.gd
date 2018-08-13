extends Control

signal pressed

onready var button = $Button
onready var label = $Label

func set_number(number):
	label.text = str(number)
	
func get_number():
	return int(label.text)
	
func decrease_number():
	set_number(get_number() - 1)
	button.disabled = get_number() <= 0

func increase_number():
	set_number(get_number() + 1)
	button.disabled = false
	
func _on_Button_button_up():
	emit_signal("pressed")