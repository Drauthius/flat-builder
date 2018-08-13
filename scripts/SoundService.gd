extends Node

var beam_placement_selection_player = AudioStreamPlayer.new()
var beam_placement_finalise_player = AudioStreamPlayer.new()

var block_placement_selection_player = AudioStreamPlayer.new()
var block_placement_finalise_player = AudioStreamPlayer.new()

var physics_start_player = AudioStreamPlayer.new()
var physics_pause_player = AudioStreamPlayer.new()

var block_destruction_player = AudioStreamPlayer.new()
var beam_joint_destruction_player = AudioStreamPlayer.new()

#var basic_music_loop01_player = AudioStreamPlayer.new()
#var basic_music_loop02_player = AudioStreamPlayer.new()

func _ready():
	beam_placement_selection_player.stream = preload("res://music/beam_placement_selection.wav")
	beam_placement_finalise_player.stream = preload("res://music/beam_placement_finalise.wav")
	
	block_placement_selection_player.stream = preload("res://music/block_placement_selection.wav")
	block_placement_finalise_player.stream = preload("res://music/block_placement_finalise.wav")
	
	physics_start_player.stream = preload("res://music/physics_start.wav")
	physics_pause_player.stream = preload("res://music/physics_pause.wav")
	
	block_destruction_player.stream = preload("res://music/block_destruction.wav")
	beam_joint_destruction_player.stream = preload("res://music/beam_joint_destruction.wav")
	
	add_child(beam_placement_selection_player)
	add_child(beam_placement_finalise_player)
	add_child(block_placement_selection_player)
	add_child(block_placement_finalise_player)
	add_child(physics_start_player)
	add_child(physics_pause_player)
	add_child(block_destruction_player)
	add_child(beam_joint_destruction_player)
	
#	physics_start_player.stream = preload("res://music/physics_start.wav")

func attach_audiostream_players(node):
	node.add_child(beam_placement_selection_player)
	node.add_child(beam_placement_finalise_player)
	node.add_child(block_placement_selection_player)
	node.add_child(block_placement_finalise_player)
	node.add_child(physics_start_player)
	node.add_child(physics_pause_player)
#	node.add_child(basic_music_loop01_player)
#	node.add_child(basic_music_loop02_player)

func beam_placement_selection():
	beam_placement_selection_player.play()

func beam_placement_finalise():
	beam_placement_finalise_player.play()

func block_placement_selection_():
	block_placement_selection_player.play()

func block_placement_finalise():
	block_placement_finalise_player.play()

func physics_start():
	physics_start_player.play()

func physics_pause():
	physics_pause_player.play()

func block_destruction():
	block_destruction_player.play()

func beam_joint_destruction():
	beam_joint_destruction_player.play()

#func basic_music_loop01():
#	basic_music_loop01_player.play()
#
#func basic_music_loop02():
#	basic_music_loop02_player.play()