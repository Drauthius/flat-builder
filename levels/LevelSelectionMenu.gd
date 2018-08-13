extends Node

func _on_Level1_pressed():
	get_tree().change_scene("res://levels/Level1.tscn")
	pass # replace with function body

func _on_Level2_pressed():
	get_tree().change_scene("res://levels/Level2.tscn")
	pass # replace with function body

func _on_Level999_pressed():
	get_tree().change_scene("res://levels/Level999.tscn")
	pass # replace with function body

func _on_Back_pressed():
	get_tree().change_scene("res://levels/MainMenu.tscn")
	pass # replace with function body
