extends Node

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

# Called when the node enters the scene tree for the first time.
func _ready():
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

func add_money(gain):
	money += gain
	money_total += gain
