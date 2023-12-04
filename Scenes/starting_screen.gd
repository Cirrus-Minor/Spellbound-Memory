extends Node2D

signal start_game

@onready var titleSprite = $"GameTitle"
@onready var UsageText = $"Usage"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	titleSprite.rotation_degrees = 5 * cos(Time.get_ticks_msec() * 0.001)
	var scale_factor = 0.85 + 0.02 * sin(Time.get_ticks_msec() * 0.002)
	titleSprite.scale = Vector2(scale_factor, scale_factor)
	UsageText.modulate.a = 0.5 + (1 + cos(Time.get_ticks_msec() * 0.008)) / 2.0

func _unhandled_input(event):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		print("emit_start")
		start_game.emit()
