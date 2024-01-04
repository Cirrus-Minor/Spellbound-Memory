extends MonsterBase

@onready var anim = $Sprite/AnimatedSprite2D

@onready var sound_attack_1 = $Sounds/Attack1
@onready var sound_attack_2 = $Sounds/Attack2
@onready var sound_hurt_1 = $Sounds/Hurt1
@onready var sound_hurt_2 = $Sounds/Hurt2
@onready var sound_die = $Sounds/Die

func on_dying():
	super()
	anim.play("die")
	await get_tree().create_timer(0.2).timeout
	sound_die.pitch_scale = randf_range(0.9, 1.1)
	sound_die.play()

func on_hurting():
	super()
	var sound = sound_hurt_1
	if randi_range(1, 2) == 2: sound = sound_hurt_2
	await get_tree().create_timer(0.2).timeout
	sound.pitch_scale = randf_range(1.1, 1.1)
	sound.play()
	anim.play("hurt")
	
func on_attack():
	anim.play("attack")
	var sound = sound_attack_1
	if randi_range(1, 2) == 2: sound = sound_attack_2
	sound.pitch_scale = randf_range(0.9, 1.1)
	sound.play()
	
func on_idle():
	anim.play("idle")

func _on_animated_sprite_2d_animation_finished():
	on_idle()
