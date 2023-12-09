extends MonsterBase

@export var delay_power = 3.0

@onready var anim = $Sprite/AnimatedSprite2D

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

func on_hurting():
	super()
	anim.play("hurt")
	
func on_attack():
	anim.play("attack")
	
func on_power():
	anim.play("power")
	timer_power = 1.0

func on_idle():
	anim.play("idle")

func _on_animated_sprite_2d_animation_finished():
	on_idle()
