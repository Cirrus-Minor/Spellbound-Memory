extends Node2D

var start_screen = preload("res://Scenes/starting_screen.tscn")
var main_fight = preload("res://Scenes/main_fight.tscn")

@onready var main_music = $Music/MainMusic
@onready var game_over_music = $Music/GameOverMusic

var _start_screen
var _fight_zone

func _ready():
	_start_screen = start_screen.instantiate()
	_start_screen.connect("start_game", _on_start_game)
	add_child(_start_screen)

func _process(delta):
	if Input.is_action_just_pressed("screenshot"):
		screenshot()
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
			
func _on_start_game():
	_start_screen.queue_free()
	main_music.play()
	generate_fight_zone(true)
			
func _on_level_up():
	_fight_zone.queue_free()
	generate_fight_zone(false)

func _on_restart_game():
	_fight_zone.queue_free()
	game_over_music.stop()
	main_music.play()
	generate_fight_zone(false)

func _on_game_over():
	main_music.stop()
	game_over_music.play()

func generate_fight_zone(start_run):
	_fight_zone = main_fight.instantiate()
	_fight_zone.connect("level_success", _on_level_up)
	_fight_zone.connect("restart_game", _on_restart_game)
	_fight_zone.connect("game_over", _on_game_over)
	if start_run:
		_fight_zone.start_run()
		
	add_child(_fight_zone)

func screenshot():
	var capture = get_viewport().get_texture().get_image()
	#var _time = Time.get_datetime_string_from_system()
	var filename = "user://Screenshot.png"
	capture.save_png(filename)
