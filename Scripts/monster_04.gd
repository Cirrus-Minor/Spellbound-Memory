extends MonsterBase

@export var delay_power = 3.0

@onready var anim = $Sprite/AnimatedSprite2D

@onready var sound_attack_1 = $Sounds/Attack1
@onready var sound_attack_2 = $Sounds/Attack2
@onready var sound_hurt_1 = $Sounds/Hurt1
@onready var sound_hurt_2 = $Sounds/Hurt2
@onready var sound_die = $Sounds/Die
@onready var sound_power = $Sounds/Power

var timer_power = 0.0

# 1 = attack
# 2 = manipulate
var current_action = 1

func _process(delta):
	super(delta)
	if timer_power >  0:
		timer_power -= delta
		if timer_power <= 0 && anim.animation == "power":
			anim.play("idle")

func process_action():
	match current_action:
		1:
			super()
			current_action = 2
			sprite_item.frame = 2
			timer_attack = delay_power
		2:
			manipulate()
			current_action = 1
			sprite_item.frame = 0
	
func manipulate():
	on_manipulate.emit(1)
	on_power()

func on_dying():
	super()
	anim.play("die")
	await get_tree().create_timer(0.2).timeout
	sound_die.pitch_scale = randf_range(0.9, 1.2)
	sound_die.play()

func on_hurting():
	super()
	anim.play("hurt")
	var sound = sound_hurt_1
	if randi_range(1, 2) == 2: sound = sound_hurt_2
	await get_tree().create_timer(0.2).timeout
	sound.pitch_scale = randf_range(0.9, 1.2)
	sound.play()
	
func on_attack():
	anim.play("attack")
	var sound = sound_attack_1
	if randi_range(1, 2) == 2: sound = sound_attack_2
	sound.pitch_scale = randf_range(0.9, 1.2)
	sound.play()
	
func on_power():
	anim.play("power")
	timer_power = 1.0
	sound_power.pitch_scale = randf_range(0.9, 1.2)
	sound_power.play()

func on_idle():
	anim.play("idle")

func _on_animated_sprite_2d_animation_finished():
	on_idle()
