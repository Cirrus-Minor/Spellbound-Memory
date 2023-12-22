extends Node2D

@onready var scores_panel = $HiScores
@onready var name_panel = $EnterName

@onready var scores_text = $HiScores/TextScores
@onready var names_text = $HiScores/TextNames

@onready var name_edit = $EnterName/NameEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _show_with_score(score):
	updates_hi_scores()

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

func updates_hi_scores():
	var scores_string = ""
	var names_string = ""
	for score_record in GameState.hi_scores:
		scores_string +=  str(score_record.score) + "\n"
		names_string += score_record.player + "\n"
	
	scores_text.text = scores_string
	names_text.text = names_string


func _on_btn_submit_name_pressed():
	var player_name = name_edit.text.strip_edges()
	if player_name == "": player_name = "Player"
	
	GameState.add_score_name(player_name)
	
	updates_hi_scores()
	
	scores_panel.show()
	name_panel.hide()
