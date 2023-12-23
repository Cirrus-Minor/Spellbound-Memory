extends Node2D

signal start_game

@onready var titleSprite = $"GameTitle"

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

func _unhandled_input(event):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		print("emit_start")
		start_game.emit()
