extends Node2D

@export var delay_after_fail = 1200.0
@export var delay_fade = 500.0
@export var delay_turn_animation = 0.07
@export var delay_deal_animation = 0.65
@export var card_frame = 1
@export var grid_index = 0 # 1 to 20

@onready var sprite = $Sprite2D

signal on_card_turned(id: int)
signal on_cards_resumed()

var is_turned = false
var is_turning_back = false
var is_revealing = false
var is_falling = false
var timer_turn = 0.0
var timer_turn_animation = 0.0
var timer_deal = 0.0
var timer_fade = 0.0
var animation_step = 1

var pos_origin
var pos_target

var velocity = Vector2(0, 0)
var spine = 0.0

func _on_input_event(_viewport, event, shape_idx):
	if not get_parent().can_select() || timer_deal > 0.0:
		return;
		
	if (event is InputEventMouseButton and event.button_index == 1 and event.pressed):
		if (!is_turned):
			turn_card()
			on_card_turned.emit(card_frame, grid_index)

func turn_card():
	timer_turn_animation = delay_turn_animation
	animation_step = 1
	
	if (is_turned):
		is_turned = false
	else:
		is_turned = true
		
	
func _process(delta):
	if (timer_deal <= 0.0 && is_turned && is_turning_back):
		if timer_turn < Time.get_ticks_msec():
			turn_card()
			
func _physics_process(delta):
	if (timer_turn_animation > 0):
		timer_turn_animation = clamp(timer_turn_animation - delta, 0, delay_turn_animation)
		if (timer_turn_animation == 0):
			if (animation_step == 1):
				animation_step = 2
				timer_turn_animation = delay_turn_animation
				if !is_turned:
					sprite.frame = 0
				else:
					sprite.frame = card_frame
			elif is_revealing:
				is_revealing = false
				is_turning_back = true
				timer_turn = Time.get_ticks_msec() + delay_after_fail
					
			if !is_turned and is_turning_back:
				on_cards_resumed.emit()
				is_turning_back = false
		
		#scale
		if (animation_step == 1):
			sprite.scale.x = timer_turn_animation / delay_turn_animation
		else:
			sprite.scale.x = 1 - timer_turn_animation / delay_turn_animation
			
	if (timer_deal > 0):
		if (is_turned):
			sprite.frame = card_frame
			
		var normalize = timer_deal / delay_deal_animation
		position.x = pos_target.x + normalize * (pos_origin.x - pos_target.x)
		position.y = pos_target.y + normalize * (pos_origin.y - pos_target.y)
		timer_deal -= delta
		
		# TODO fine tuning
		normalize = 1 - abs(0.5 - normalize) * 2
		scale.x = 1 + 3.5 * normalize
		scale.y = 1 + 3.5 * normalize
		rotation_degrees = normalize * -15
		position.x += normalize * -200
		position.y -= normalize * -200
		
		if (timer_deal <= 0):
			position = pos_target
			scale = Vector2(1, 1)
			rotation_degrees = 0
		
	if (is_falling):
		velocity.y += delta * 1000
		position += velocity * delta
		
func init_card(param_grid_index, param_card_frame, show_card):
	self.grid_index = param_grid_index
	self.card_frame = param_card_frame
	var x_array = grid_index % GameState.CARDS_PER_ROW
	var y_array = grid_index / GameState.CARDS_PER_ROW
	
	# dealing cards
	pos_target = Vector2(96 + (x_array) * 135, 92 + (y_array) * 133)
	pos_origin = Vector2(700,580)
	position = pos_origin
	timer_deal = delay_deal_animation
	
	if (show_card):
		is_turned = true
		
func on_matched():
	if !is_turned:
		return
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)
	
func on_not_matched():
	if !is_turned:
		return
		
	is_turning_back = true
	timer_turn = Time.get_ticks_msec() + delay_after_fail

func set_show_timer(delay):
	if !is_turned:
		return
		
	is_turning_back = true
	timer_turn = Time.get_ticks_msec() + delay

func reveal_card(param_grid_index):
	if !is_turned && grid_index == param_grid_index:
		is_revealing = true
		turn_card()

func make_fall():
	timer_turn = 0.0
	timer_turn_animation = 0.0
	timer_deal = 0.0
	timer_fade = 0.0
	is_falling = true
	velocity = Vector2(randf_range(-100, 100), randf_range(0, 300))
