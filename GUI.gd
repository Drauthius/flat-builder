extends MarginContainer

onready var money_label = $"VBoxContainer/HBoxContainer/Money"

func set_money(amount):
	money_label.text = str(amount)