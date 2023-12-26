extends Node

const VERSION = "0.4.0"
const AUTHOR = "Cirrus Minor"

const SAVE_FILE = "user://savegame.tres"

const CARDS_PER_ROW = 4
const CARDS_NUMBER = 20

# Initial Deck
@export var Deck = [];

var player_health = 5
var player_health_max = 5
var player_shields = 3
var player_shields_max = 3

var level = 1
var money = 0
var money_total = 0 # will be used for scoring

var hi_scores = []
var score_record = load("res://Scripts/score_record.gd")

var last_player_name = ""
	
# Called when the node enters the scene tree for the first time.
func _ready():
	load_scores()
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset():
	player_health = 8
	player_health_max = 8
	player_shields = 3
	player_shields_max = 3
	level = 1
	money = 0
	money_total = 0
	Deck = [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7];
	
	#Quick Death
	#player_health = 1
	#player_shields = 1

func add_money(gain):
	money += gain
	money_total += gain

func has_new_score():
	return money_total > hi_scores[4].score

static func sort_score(a, b):
		return (a.score > b.score)
		
func add_score_name(player):
	last_player_name = player
	var record = score_record.new(player, money_total, level)
	hi_scores.push_back(record)
	hi_scores.sort_custom(sort_score)
	hi_scores.pop_back()
	save_scores()
	
func start_game():
	load_game()
	
func save_scores():
	var file_content = []
	for record in hi_scores:
		var file_entry = { "player": record.player, "score": record.score, "level": record.level }
		file_content.push_back(file_entry)
	var file_content_JSON = JSON.stringify(file_content)
	
	var save_game = FileAccess.open("user://scores.sav", FileAccess.WRITE)
	save_game.store_line(file_content_JSON)

func load_scores():
	if not FileAccess.file_exists("user://scores.sav"):
		generate_score_data()
		
	var save_game = FileAccess.open("user://scores.sav", FileAccess.READ)
	var json_string = save_game.get_as_text()
	hi_scores = JSON.parse_string(json_string)
	if hi_scores == null || hi_scores.size() < 5:
		generate_score_data()
		
func generate_score_data():
	hi_scores = []
	var record = score_record.new("Sylvea", 250, 7)
	hi_scores.push_back(record)
	record = score_record.new("Nym", 200, 6)
	hi_scores.push_back(record)
	record = score_record.new("Elara", 150, 5)
	hi_scores.push_back(record)
	record = score_record.new("Eldric", 100, 4)
	hi_scores.push_back(record)
	record = score_record.new("Evron", 50, 3)
	hi_scores.push_back(record)
	save_scores()

func save_game():
	var savegame = GameSave.new() #preload("res://Scripts/game-save.gd").new()
	savegame.version = VERSION
	savegame.level = level
	savegame.money = money
	savegame.money_total = money_total
	savegame.player_health = player_health
	savegame.player_health_max = player_health_max
	savegame.player_shields_max = player_shields_max
	ResourceSaver.save(savegame, SAVE_FILE)
	
func load_game():
	reset()
	if FileAccess.file_exists(SAVE_FILE):
		var savegame = ResourceLoader.load(SAVE_FILE)
		if savegame is GameSave: # Check that the data is valid
			level = savegame.level + 1
			money = savegame.money
			money_total = savegame.money_total
			player_health = savegame.player_health
			player_health_max = savegame.player_health_max
			player_shields_max = savegame.player_shields_max
			
		DirAccess.remove_absolute(SAVE_FILE)

