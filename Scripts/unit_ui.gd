extends Node2D

@onready var health_text = $"Health-container/HealthText"
@onready var shield_text = $"Shield/ShieldsText"
@onready var health_bar = $"Health-container/Health"
@onready var shield_sprite = $"Shield"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update(hp, hp_max, shield, shield_max):
	health_text.text = str(hp) + "/" + str(hp_max)
	health_bar.scale = Vector2((0.0 + hp) / hp_max, 1.0)
	
	if (shield == 0):
		shield_sprite.modulate.a = 0.3
		shield_text.text = ""
	else:
		shield_sprite.modulate.a = 1.0
		if (shield == shield_max):
			shield_text.modulate.a = 1.0
		else:
			shield_text.modulate.a = 0.75
		shield_text.text = str(shield)
	
