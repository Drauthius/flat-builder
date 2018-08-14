extends MarginContainer

signal start_game
signal place_apartment

onready var mode_label = $CanvasLayer/VBoxContainer/TopContainer/Mode
onready var start_button = $CanvasLayer/VBoxContainer/ButtonsContainer/Buttons/VBoxContainer/StartButton

onready var money_symbol = $CanvasLayer/VBoxContainer/TopContainer/MoneySymbol
onready var money_label = $CanvasLayer/VBoxContainer/TopContainer/Money

onready var apt_1_label = $"CanvasLayer/VBoxContainer/ObjectivesContainer/Background/ColorRect/MarginContainer/VBoxContainer/1RoomApartments/Label2"
onready var apt_2_label = $"CanvasLayer/VBoxContainer/ObjectivesContainer/Background/ColorRect/MarginContainer/VBoxContainer/2RoomApartments/Label2"
onready var apt_3_label = $"CanvasLayer/VBoxContainer/ObjectivesContainer/Background/ColorRect/MarginContainer/VBoxContainer/3RoomApartments/Label2"
onready var apt_1_checkbox = $"CanvasLayer/VBoxContainer/ObjectivesContainer/Background/ColorRect/MarginContainer/VBoxContainer/1RoomApartments/CheckBox"
onready var apt_2_checkbox = $"CanvasLayer/VBoxContainer/ObjectivesContainer/Background/ColorRect/MarginContainer/VBoxContainer/2RoomApartments/CheckBox"
onready var apt_3_checkbox = $"CanvasLayer/VBoxContainer/ObjectivesContainer/Background/ColorRect/MarginContainer/VBoxContainer/3RoomApartments/CheckBox"

onready var apt_1_button = $"CanvasLayer/VBoxContainer/ButtonsContainer/Buttons/1RoomApartmentButton"
onready var apt_2_button = $"CanvasLayer/VBoxContainer/ButtonsContainer/Buttons/2RoomApartmentButton"
onready var apt_3_button = $"CanvasLayer/VBoxContainer/ButtonsContainer/Buttons/3RoomApartmentButton"

onready var apt_labels = { 1: apt_1_label, 2: apt_2_label, 3: apt_3_label }
onready var apt_checkboxes = { 1: apt_1_checkbox, 2: apt_2_checkbox, 3: apt_3_checkbox }
onready var apt_buttons = { 1: apt_1_button, 2: apt_2_button, 3: apt_3_button }
onready var apt_nums = { 1: 0, 2: 0, 3: 0 }
onready var apt_goal = { 1: 0, 2: 0, 3: 0 }

func set_build_mode():
	mode_label.text = "Build Mode"
	mode_label.add_color_override("font_color", Color(1.0, 1.0, 0.6))
	start_button.disabled = false
	start_button.pressed = false

func set_simulation_mode():
	mode_label.text = "Simulation Mode"
	mode_label.add_color_override("font_color", Color(0.6, 1.0, 1.0))
	start_button.pressed = true
	start_button.disabled = true

func set_winning_mode():
	mode_label.text = "Winner!"
	mode_label.add_color_override("font_color", Color(0.6, 1.0, 0.6))
	start_button.disabled = false
	start_button.pressed = false

func set_money(amount):
	money_label.text = str(amount)

func set_insufficient(insufficient):
	var color
	
	if insufficient:
		color = Color(1, 0.2, 0.2)
	else:
		color = Color(1, 1, 1)
	
	money_symbol.add_color_override("font_color", color)
	money_label.add_color_override("font_color", color)

func set_objective(apt_1, apt_2, apt_3):
	apt_1_label.text = "0/%d" % apt_1
	apt_2_label.text = "0/%d" % apt_2
	apt_3_label.text = "0/%d" % apt_3
	
	apt_goal[1] = apt_1
	apt_goal[2] = apt_2
	apt_goal[3] = apt_3
	
	for i in range(1, 4):
		if apt_goal[i] <= 0:
			apt_checkboxes[i].pressed = true

func set_maximum(apt_1, apt_2, apt_3):
	apt_1_button.set_number(apt_1)
	apt_2_button.set_number(apt_2)
	apt_3_button.set_number(apt_3)

func add_apartment(rooms):
	apt_nums[rooms] += 1
	apt_labels[rooms].text = "%d/%d" % [apt_nums[rooms], apt_goal[rooms]]
	
	apt_checkboxes[rooms].pressed = apt_nums[rooms] >= apt_goal[rooms]
	apt_buttons[rooms].decrease_number()

func remove_apartment(rooms):
	apt_nums[rooms] -= 1
	apt_labels[rooms].text = "%d/%d" % [apt_nums[rooms], apt_goal[rooms]]
	
	apt_checkboxes[rooms].pressed = apt_nums[rooms] >= apt_goal[rooms]
	apt_buttons[rooms].increase_number()
	print("remove")

func _on_MenuButton_pressed():
	get_tree().change_scene("res://levels/MainMenu.tscn")

func _on_RestartButton_button_up():
	get_tree().reload_current_scene()

func _on_StartButton_button_up():
	emit_signal("start_game")

func _on_1RoomApartmentButton_pressed():
	emit_signal("place_apartment", 1)

func _on_2RoomApartmentButton_pressed():
	emit_signal("place_apartment", 2)

func _on_3RoomApartmentButton_pressed():
	emit_signal("place_apartment", 3)