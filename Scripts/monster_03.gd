extends MonsterBase

@onready var anim = $Sprite/AnimatedSprite2D

var timer_power = 0.0

# 1 = attack
# 2 = revive
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
		2:
			revive_monster()
			
	next_action()
	
func next_action():
	if current_action == 1 && dead_monsters > 0:
		current_action = 2
		sprite_item.frame = 3
	else:
		current_action = 1
		sprite_item.frame = 0

func revive_monster():
	on_revive_monster.emit(1)
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
