var beam_placement_selection_player = AudioStreamPlayer.new()
var beam_placement_finalise_player = AudioStreamPlayer.new()

var block_placement_selection_player = AudioStreamPlayer.new()
var block_placement_finalise_player = AudioStreamPlayer.new()

var basic_music_loop01_player = AudioStreamPlayer.new()

func _init():
	beam_placement_selection_player.stream = preload("res://music/beam_placement_selection.wav")
	beam_placement_finalise_player.stream = preload("res://music/beam_placement_finalise.wav")
	
	block_placement_selection_player.stream = preload("res://music/block_placement_selection.wav")
	block_placement_finalise_player.stream = preload("res://music/block_placement_finalise.wav")
	
	basic_music_loop01_player.stream = preload("res://music/01basic_music_loop.tres")

func attach_audiostream_players(node):
	node.add_child(beam_placement_selection_player)
	node.add_child(beam_placement_finalise_player)
	node.add_child(block_placement_selection_player)
	node.add_child(block_placement_finalise_player)
	node.add_child(basic_music_loop01_player)

func beam_placement_selection():
	beam_placement_selection_player.play()

func beam_placement_finalise():
	beam_placement_finalise_player.play()

func block_placement_selection_():
	block_placement_selection_player.play()

func block_placement_finalise():
	block_placement_finalise_player.play()

func basic_music_loop01():
	basic_music_loop01_player.play()