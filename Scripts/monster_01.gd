extends MonsterBase

@onready var anim = $Sprite/AnimatedSprite2D

func on_dying():
	super()
	anim.play("die")

func on_hurting():
	super()
	anim.play("hurt")
	
func on_attack():
	anim.play("attack")

func on_idle():
	anim.play("idle")

func _on_animated_sprite_2d_animation_finished():
	on_idle()
