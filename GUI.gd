extends MarginContainer

signal start_game

onready var money_symbol = $VBoxContainer/TopContainer/MoneySymbol
onready var money_label = $VBoxContainer/TopContainer/Money

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

func _on_MenuButton_pressed():
	get_tree().change_scene("res://levels/MainMenu.tscn")

func _on_RestartButton_button_up():
	get_tree().reload_current_scene()

func _on_StartButton_button_up():
	emit_signal("start_game")