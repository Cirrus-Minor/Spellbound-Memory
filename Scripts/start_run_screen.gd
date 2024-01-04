extends Node2D

@onready var card_info = $CardInfo
@onready var effect_1 = $Card1/Effect
@onready var effect_2 = $Card2/Effect
@onready var effect_3 = $Card3/Effect

# Called when the node enters the scene tree for the first time.
func _ready():
	effect_1.show()
	card_info.init_card(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_card_input_event(event, card_number):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		effect_1.hide()
		effect_2.hide()
		effect_3.hide()
		match card_number:
			1:
				effect_1.show()
				card_info.init_card(2)
				
			2:
				effect_2.show()
				card_info.init_card(7)
				
			3:
				effect_3.show()
				card_info.init_card(6)


func _on_card_1_input_event(viewport, event, shape_idx):
	on_card_input_event(event, 1)


func _on_card_2_input_event(viewport, event, shape_idx):
	on_card_input_event(event, 2)


func _on_card_3_input_event(viewport, event, shape_idx):
	on_card_input_event(event, 3)
