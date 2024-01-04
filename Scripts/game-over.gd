extends Node2D

@onready var scores_panel = $HiScores
@onready var name_panel = $EnterName

@onready var scores_list = $HiScores/ListScores
@onready var names_list = $HiScores/ListNames
@onready var index_list = $HiScores/ListIndexes

@onready var name_edit = $EnterName/NameEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _show_with_score(score):
	updates_hi_scores(false)

	if GameState.has_new_score():
		name_edit.text = GameState.last_player_name
		if GameState.last_player_name == "":
			name_edit.grab_focus()
			
		scores_panel.hide()
		name_panel.show()
	else:
		scores_panel.show()
		name_panel.hide()
	show()

func give_effect(text):
	text =  "[shake rate=20.0 level=5 connected=1][rainbow freq=0.6 sat=0.6 val=0.8]" + text + "[/rainbow][/shake]\n"
	return text
	
func updates_hi_scores(show_new_score):
	var current_entry = 1
	var show_new_score_done = false
	var show_current_player = false
	var scores_string = ""
	var names_string = ""
	var indexes_string = ""
	for score_record in GameState.hi_scores:
		if !show_new_score_done && score_record.score == GameState.money_total && score_record.player == GameState.last_player_name:
			show_new_score_done = true
			show_current_player = show_new_score
			
		if show_current_player:
			scores_string +=  give_effect(str(score_record.score))
			names_string +=  give_effect(score_record.player)
			indexes_string +=  give_effect(str(current_entry))
		else:
			scores_string +=  str(score_record.score) + "\n"
			names_string += score_record.player + "\n"
			indexes_string +=  str(current_entry) + "\n"
			
		show_current_player = false
		current_entry += 1
	
	scores_list.text = scores_string
	names_list.text = names_string
	index_list.text = indexes_string

func _on_btn_submit_name_pressed():
	var player_name = name_edit.text.strip_edges()
	if player_name == "": player_name = "Player"
	
	GameState.add_score_name(player_name)
	
	updates_hi_scores(true)
	
	scores_panel.show()
	name_panel.hide()
