extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var shield_sprite = $Shield
@onready var hit_paticles = $HitParticles

var is_dead = false
var is_victory = false
var velocity = 0
var position_y = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	position_y = position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if is_dead && rotation_degrees > -90:
		rotation_degrees -= delta * 150
		
	if is_victory:
		position.y += velocity * delta
		velocity += delta * 2500
		
		if position.y > position_y:
			position.y = position_y
			velocity = -800
		
func hurt():
	sprite.play("hurt")
	hit_paticles.process_material.direction = Vector3(1, -0.5, 0)
	hit_paticles.emitting = true
	
func shield():
	var tween = get_tree().create_tween()
	shield_sprite.modulate.a = 0.8
	shield_sprite.show()
	tween.tween_property(shield_sprite, "modulate:a", 0.0, 0.3)
	
func attack():
	sprite.play("attack")
	
func victory():
	is_victory = true
	sprite.play("victory")
	velocity = -800
	
func cast_magic():
	sprite.play("magic")
	
func die():
	is_dead = true
	sprite.play("die")

func _on_animated_sprite_2d_animation_finished():
	sprite.play("idle")
