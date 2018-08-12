extends Node2D

var cost setget set_cost, get_cost

onready var money_label = $HBoxContainer/Money
onready var money_symbol = $HBoxContainer/MoneySymbol

func set_cost(amount, insufficient):
	var color = null
	
	if amount == 0 or insufficient:
		color = Color(1, 0.2, 0.2)
	else:
		color = Color(1, 1, 1)
	
	money_label.add_color_override("font_color", color)
	money_symbol.add_color_override("font_color", color)
	
	money_label.text = str(amount)

func get_cost():
	return int(money_label.text)