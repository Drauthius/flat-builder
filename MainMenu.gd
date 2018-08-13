extends Node

func _ready():
	SoundService.stop_all_music()
	SoundService.mainmenu_music_loop01()

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_StartButton_pressed():
	get_tree().change_scene("res://levels/LevelSelectionMenu.tscn")
#	get_tree().change_scene("res://levels/Level1.tscn")
	pass