extends Node2D

@onready var sprite = $Sprite
@onready var text_title = $Title
@onready var text_content = $Content

var frame = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init_card(new_frame):
	frame = new_frame
	sprite.frame = frame
	
	match frame:
		1:
			text_title.text = "Fireball"
			text_content.text = "The [b]Fireball[/b] is an attack spell that inflicts [b]5 damages[/b] to the first monster."
			
		2:
			text_title.text = "Magic Missile"
			text_content.text = "The [b]Magic Missile[/b] is an attack spell that inflicts [b]1 damage[/b] to the first monster."
			
		3:
			text_title.text = "Thunder"
			text_content.text = "The [b]Thunder[/b] is an area attack spell that inflicts [b]2 damages[/b] to each monster."
			
		4:
			text_title.text = "Hand of Fate"
			text_content.text = "The [b]Hand of Fate[/b] is a spell refilling the cards field."
			
		5:
			text_title.text = "Healing Spell"
			text_content.text = "The [b]Healing Spell[/b] is a spell that heals [b]1 HP[/b] to the player."

		6:
			text_title.text = "Eye of the Wizard"
			text_content.text = "The [b]Eye of the Wizard[/b] is a spell revealing [b]4 cards[/b]."
			
		7:
			text_title.text = "Magic Shield"
			text_content.text = "The [b]Magic Shield[/b] is an protective spell that regenerates [b]1 shield[/b]."
			
		8:
			text_title.text = "Wealth"
			text_content.text = "The [b]Wealth[/b] is a spell generating [b]5 coins[/b]."
