extends Node2D

@onready var score_text = $TextFinalScore

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _show_with_score(score):
	score_text.text = "Your score:\n$ " + str(score)
	show()
