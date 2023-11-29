extends Node2D

@onready var card_info = $CardInfo

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init_card(new_frame):
	card_info.init_card(new_frame)
