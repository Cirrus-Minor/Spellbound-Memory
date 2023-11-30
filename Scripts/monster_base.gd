extends Node2D
class_name MonsterBase

@export var timer_attack = 6.0
@export var delay_attack = 8.0
@export var health_max = 3
@export var shields_max = 2
@export var damages = 2
@export var bounty = 10

@onready var monster_ui = $UnitUI
@onready var sprite = $Sprite
@onready var sprite_revive = $ReviveSprite
@onready var sprite_ui = $Sprite/UI
@onready var sprite_item = $Sprite/UI/Item
@onready var time_text = $Sprite/UI/Time
@onready var hit_particles = $Sprite/HitParticles
@onready var sound_coins = $Sounds/SoundCoins

var health = health_max
var shields = shields_max
var is_dead = false
var velocity_y = 0
var is_starting = true

var dead_monsters = 0 # how many dead monsters in the field? (for revive power)

signal on_monster_attack(damages)
signal on_revive_monster(amount)

func _ready():
	shields = shields_max
	health = health_max
	sprite_ui.hide()
	
	_update_ui()
	hit_particles.emitting = false
	
	sprite.position.x += 400
	velocity_y = -600
	is_starting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_dead:
		timer_attack -= delta
		if timer_attack < 0:
			timer_attack = delay_attack
			process_action()
			
		time_text.text = str(ceil(timer_attack)).pad_decimals(0)
		if timer_attack < 2.5:
			var color_add = 1.5 + 0.5 * cos(Time.get_ticks_msec() / 100.0)
			sprite_item.modulate.r = color_add 
			sprite_item.modulate.g = color_add
			sprite_item.modulate.b = color_add
		else:
			sprite_item.modulate.r = 1
			sprite_item.modulate.g = 1
			sprite_item.modulate.b = 1
			
# override for alternative actions
func process_action():
	on_monster_attack.emit(damages)
	on_attack()
	sprite.position.x -= 100
			
func _physics_process(delta):
	if (sprite.position.x < 0):
		sprite.position.x += delta * 1000
		if (sprite.position.x > 0):
			sprite.position.x = 0
			
	if is_starting:
		sprite.position.y += delta * velocity_y
		velocity_y += delta * 1200
		sprite.position.x -= delta * 400
		if sprite.position.x < 0: sprite.position.x = 0
		if (sprite.position.y > 0):
			sprite.position = Vector2(0, 0)
			is_starting = false
			sprite_ui.show()
			
	if is_dead && sprite.position.y < 0:
		sprite.position.y += delta * velocity_y
		velocity_y += delta * 1200
		if (sprite.position.y > 0):
			sprite.position = Vector2(0, 0)
			
func hurt(damages):
	if shields >= damages:
		shields -= damages
	else:
		damages -= shields
		shields = 0
		health -= damages
		
	if health < 1:
		health = 0
		is_dead = true
		velocity_y = -400
		sprite.position.y = - 2
		sprite_ui.hide()
		if bounty > 0:
			sound_coins.pitch_scale = randf_range(0.9, 1.1)
			sound_coins.play()
			GameState.add_money(bounty)
			bounty = 0
		
		on_dying()
	else:
		on_hurting()
		
	_update_ui()
	
func revive():
	is_dead = false
	health = health_max
	timer_attack = delay_attack * 1.5
	_update_ui()
	on_idle()
	sprite_ui.show()
	sprite_revive.modulate.a = 0.8
	sprite_revive.show()
	var tween = get_tree().create_tween()
	tween.tween_property(sprite_revive, "modulate:a", 0.0, 1.5).set_trans(Tween.TRANS_CUBIC)
	
# group calls
func update_dead_monsters(n):
	dead_monsters = n
	
# for override
func on_dying():
	hit_particles.process_material.direction = Vector3(-1, -0.5, 0)
	hit_particles.emitting = true

func on_hurting():
	hit_particles.process_material.direction = Vector3(-1, -0.5, 0)
	hit_particles.emitting = true
	
func on_attack():
	pass

func on_idle():
	pass
	
func _update_ui():
	monster_ui.update(health, health_max, shields, shields_max)
