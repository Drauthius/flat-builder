extends Node

func _on_Level1_pressed():
	SoundService.stop_all_music()
	SoundService.basic_music_loop01()
	get_tree().change_scene("res://levels/Level1.tscn")
	pass # replace with function body

func _on_Level2_pressed():
	SoundService.stop_all_music()
	SoundService.basic_music_loop01()
	get_tree().change_scene("res://levels/Level2.tscn")
	pass # replace with function body

func _on_Level999_pressed():
	SoundService.stop_all_music()
	SoundService.basic_music_loop02()
	get_tree().change_scene("res://levels/Level999.tscn")
	pass # replace with function body

func _on_Back_pressed():
	get_tree().change_scene("res://levels/MainMenu.tscn")
	pass # replace with function body
