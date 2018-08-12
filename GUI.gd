extends MarginContainer

onready var money_symbol = $VBoxContainer/HBoxContainer/MoneySymbol
onready var money_label = $VBoxContainer/HBoxContainer/Money

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