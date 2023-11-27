extends Node2D

var main_fight = preload("res://Scenes/main_fight.tscn")
var _fight_zone

func _ready():
	# At the moment, only fighting
	generate_fight_zone()

func _process(delta):
	pass

func _on_level_up():
	_fight_zone.queue_free()
	generate_fight_zone()

func _on_game_over():
	_fight_zone.queue_free()
	generate_fight_zone()

func generate_fight_zone():
	_fight_zone = main_fight.instantiate()
	_fight_zone.connect("level_success", _on_level_up)
	_fight_zone.connect("game_over", _on_game_over)
	add_child(_fight_zone)
