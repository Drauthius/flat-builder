extends Node

func _ready():
	pass

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_StartButton_pressed():
	get_tree().change_scene("res://levels/Level1.tscn")
