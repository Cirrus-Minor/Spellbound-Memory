extends Node2D

enum Game_state {
	Starting,
	DealCards,
	WaitForCard1,
	WaitForCard2,
	MatchFail,
	GameOver,
	Victory
}

const monster_pos_1 = 1200
const monster_pos_2 = 1050
const monster_pos_3 = 900

signal level_success
signal restart_game
signal game_over

@onready var combo_text = $CardStack/ComboText
@onready var combo_effect_sprite = $CardStack/ComboEffect
@onready var player = $Player
@onready var player_ui = $UnitUI
@onready var level_text = $HUD/Level
@onready var money_text = $HUD/Money
@onready var game_over_ui = $Interface/GameOver
@onready var next_level_new_card_ui = $Interface/LevelEndNewCard
@onready var start_run_ui = $Interface/StartRunScreen
@onready var sound_combo_end = $Sounds/ComboEnd
@onready var sound_combo_01 = $Sounds/Combo/Combo01
@onready var sound_combo_02 = $Sounds/Combo/Combo02
@onready var sound_combo_03 = $Sounds/Combo/Combo03
@onready var sound_combo_04 = $Sounds/Combo/Combo04
@onready var sound_combo_05 = $Sounds/Combo/Combo05
@onready var sound_combo_06 = $Sounds/Combo/Combo06
@onready var sound_combo_07 = $Sounds/Combo/Combo07
@onready var sound_combo_08 = $Sounds/Combo/Combo08
@onready var sound_combo_09 = $Sounds/Combo/Combo09
@onready var sound_combo_10 = $Sounds/Combo/Combo10
@onready var sound_cards_deal = $Sounds/CardsDeal
@onready var sound_card_turn = $Sounds/CardTurn
@onready var sound_revive = $Sounds/Revive
@onready var sound_coin = $Sounds/Coin
@onready var sound_coins = $Sounds/Coins

@export var can_select_card = true

var card_class = preload("res://Scenes/memory_card.tscn")
var monster_01 = preload("res://Scenes/monster_01.tscn")
var monster_02 = preload("res://Scenes/monster_02.tscn")
var monster_03 = preload("res://Scenes/monster_03.tscn")
var monster_04 = preload("res://Scenes/monster_04.tscn")

var full_deck = []
var rest_deck = []
var pile_deck = []

var current_cards = []
var remaining_pairs = 0
var remaining_places = []

var state: Game_state = Game_state.WaitForCard1
var card1_index = 0
var card2_index = 0
var card1_grid_index = 0
var card2_grid_index = 0

var combo = 0
var money_display = 0

var player_health = 5
var player_health_max = 5
var player_shields = 3
var player_shields_max = 3

var monsters = []

func start_level():
	generate_monsters()
	update_combo(0)
	state = Game_state.WaitForCard1
	full_deck = GameState.Deck.duplicate()
	rest_deck = full_deck.duplicate()
	for n in 20:
		remaining_places.push_back(n)
	process_cards(4)
	
func start_run():
	state = Game_state.Starting
	
func _on_btn_start_pressed():
	start_run_ui.hide()
	start_level()
	
func _ready():
	player_health = GameState.player_health
	player_health_max = GameState.player_health_max
	player_shields = GameState.player_shields
	player_shields_max = GameState.player_shields_max
	update_player()
	
	level_text.text = "LVL " + str(GameState.level)
	money_display = GameState.money
	combo_text.text = ""
	combo_effect_sprite.hide()
	
	if state == Game_state.Starting:
		start_run_ui.show()
	else:
		start_level()
	
func _process(delta):
	if money_display < GameState.money: money_display += 1
	elif money_display > GameState.money: money_display -= 1
	money_text.text = "$ " + str(money_display)
	
func _physics_process(delta):
	combo_effect_sprite.rotation_degrees += delta * 30
		
func process_cards(cards_to_reveal):
	# clear cards to display
	var new_cards = []
	
	# pick cards from the rest deck
	for n in remaining_places.size() / 2:
		if rest_deck.size() == 0:
			rest_deck = pile_deck.duplicate()
			pile_deck.clear()
			
		var card_deck = rest_deck.pop_at(randi_range(0, rest_deck.size() - 1))
		pile_deck.append(card_deck)
		current_cards.append(card_deck)
		current_cards.append(card_deck)
		new_cards.append(card_deck)
		new_cards.append(card_deck)
		remaining_pairs += 1
		
	# create Memory cards 
	deal_cards(new_cards, cards_to_reveal)

func get_cards_to_reveal(n):
	if n < 0:
		return []
	
	var complete_deck = []
	var reveal_deck = []
	
	for i in 20:
		complete_deck.push_back(i)
	
	complete_deck.shuffle()
	for i in n:
		reveal_deck.push_back(complete_deck.pop_back())
		
	return reveal_deck
	
func deal_cards(new_cards, cards_to_reveal):
	remaining_places.sort()
	state = Game_state.DealCards
	
	var to_reveal = get_cards_to_reveal(cards_to_reveal)
	var nothing_to_reveal = true
	
	new_cards.shuffle()
	
	sound_cards_deal.play()
	
	for mem_card in new_cards:
		var index = remaining_places.pop_front()
		await get_tree().create_timer(0.045).timeout
		
		if state == Game_state.Victory || state == Game_state.GameOver:
			return
		
		var new_card = card_class.instantiate()
		new_card.on_card_turned.connect(_on_card_turned)
		new_card.on_cards_resumed.connect(_on_cards_resumed)
		new_card.init_card(index, mem_card, to_reveal.has(index))
		if nothing_to_reveal && to_reveal.has(index):
			nothing_to_reveal = false
			
		add_child(new_card)
		
	if (nothing_to_reveal):
		state = Game_state.WaitForCard1
	else:
		get_tree().call_group("cards", "set_show_timer", 1200.0)
		state = Game_state.MatchFail
		
	sound_cards_deal.stop()
	
	
func can_select():
	return state == Game_state.WaitForCard1 || state == Game_state.WaitForCard2
	
func _on_card_turned(index, grid_index):
	sound_card_turn.pitch_scale = randf_range(0.8, 1.4)
	sound_card_turn.play()
	if state == Game_state.WaitForCard1:
		card1_index = index
		card1_grid_index = grid_index
		state = Game_state.WaitForCard2
	elif state == Game_state.WaitForCard2:
		card2_index = index
		card2_grid_index = grid_index
		_match_test()
		
func _on_cards_resumed():
	can_select_card = true
	state = Game_state.WaitForCard1
	
func _match_test():
	if (card1_index == card2_index):
		get_tree().call_group("cards", "on_matched")
		update_combo(combo + 1)
		remaining_pairs -= 1
		remaining_places.push_back(card1_grid_index)
		remaining_places.push_back(card2_grid_index)

		state = Game_state.WaitForCard1
		activate_card(card1_index)
		if (remaining_pairs == 0):
			process_cards(4)
	
	else:
		get_tree().call_group("cards", "on_not_matched")
		update_combo(0)
		can_select_card = false
		state = Game_state.MatchFail
		
			
func reveal_cards(n):
	if n < 0 || remaining_places.size() > 16:
		return
	
	var complete_deck = []
	
	for i in 20:
		if !remaining_places.has(i):
			complete_deck.push_back(i)
	
	complete_deck.shuffle()
	var n_max = n
	if complete_deck.size() < n :
		n_max = complete_deck.size()
		
	for i in n_max:
		get_tree().call_group("cards", "reveal_card", complete_deck[i])
		
	if (state == Game_state.GameOver || state == Game_state.Victory): return
	
	state = Game_state.MatchFail
		
func update_combo(new_combo):
	if combo > 0 && new_combo == 0:
		sound_combo_end.play()

	combo = new_combo
	if (combo < 3):
		combo_text.text = ""
		combo_effect_sprite.hide()
	else:
		combo_text.text = "Combo X" + str(combo)
		combo_effect_sprite.show()
		GameState.add_money(2)
		sound_coin.play()
		
	if combo > 0:
		play_combo_sound(combo)

func is_combo_power():
	return combo > 3

func play_combo_sound(combo):
	print(combo)
	match combo:
		1: sound_combo_01.play()
		2: sound_combo_02.play()
		3: sound_combo_03.play()
		4: sound_combo_04.play()
		5: sound_combo_05.play()
		6: sound_combo_06.play()
		7: sound_combo_07.play()
		8: sound_combo_08.play()
		9: sound_combo_09.play()
		_:
			if combo % 2 == 0 : sound_combo_10.play()
			else : sound_combo_09.play()
			
func _on_monster_attack(damages):
	if player_health < 1:
		return
		
	if player_shields >= damages:
		player_shields -= damages
		player.shield()
	else:
		player.hurt()
		damages -= player_shields
		player_shields = 0
		player_health -= damages
		
	if player_health < 1:
		process_game_over()
		
	update_player()

func update_player():
	player_ui.update(player_health, player_health_max, player_shields, player_shields_max)

func attack_monster(damages, area_attack):
	var combat_done = false
	for monster in monsters:
		if !combat_done and !monster.is_dead:
			monster.hurt(damages)
			combat_done = !area_attack
		
	check_victory()
	
func revive_monster(amount):
	var revive_done = 0
	for monster in monsters:
		if revive_done < amount && monster.is_dead:
			monster.revive()
			revive_done += 1
			
	if revive_done > 0:
		sound_revive.play()
		
	check_victory()
	
func manipulate_cards(amount):
	var complete_deck = []
	for node in get_tree().get_nodes_in_group("cards"):
			if (node.can_be_swapped()):
				complete_deck.push_back(node.grid_index)

	if (complete_deck.size() > 1):
		complete_deck.shuffle()
		get_tree().call_group("cards", "swap_cards", complete_deck.pop_back(), complete_deck.pop_back())
	
func check_victory():
	if state == Game_state.GameOver: return
	var is_victory = true
	var dead_monsters = 0
	for monster in monsters:
		if monster.is_dead:
			dead_monsters += 1
		else:
			is_victory = false
			
	if (is_victory):
		victory()
	
	get_tree().call_group("monsters", "update_dead_monsters", dead_monsters)
	
func victory():
	state = Game_state.Victory
	player.victory()
	await get_tree().create_timer(1.0).timeout
	state = Game_state.Victory
	get_tree().call_group("cards", "make_fall")
	
	var loot = [1, 3, 4, 5, 6, 8] 
	var new_card = loot.pick_random()
	GameState.Deck.push_back(new_card)

	next_level_new_card_ui.init_card(new_card)
	next_level_new_card_ui.show()

func process_game_over():
	player_health = 0
	player.die()
	state = Game_state.GameOver
	await get_tree().create_timer(1.0).timeout
	get_tree().call_group("cards", "make_fall")
	state = Game_state.GameOver
	game_over_ui._show_with_score(GameState.money_total)
	game_over.emit()
	
func _on_btn_play_again_pressed():
	GameState.reset()
	restart_game.emit()

func _on_btn_exit_pressed():
	get_tree().quit()
	
func _on_btn_continue_pressed():
	GameState.player_health = player_health
	GameState.player_health_max = player_health_max
	GameState.player_shields = player_shields_max
	GameState.player_shields_max = player_shields_max
	GameState.level += 1
	level_success.emit()
	
#region Level factory
func generate_monsters():
	monsters.clear()
	
	match GameState.level:
		1:
			add_monster(monster_01, monster_pos_1, 10)
		
		2:
			add_monster(monster_01, monster_pos_1, 12)
			add_monster(monster_01, monster_pos_2, 8)
			
		3:
			add_monster(monster_01, monster_pos_1, 12)
			add_monster(monster_02, monster_pos_2, 8)

		4:
			add_monster(monster_01, monster_pos_1, 12)
			add_monster(monster_01, monster_pos_2, 10)
			add_monster(monster_01, monster_pos_3, 8)
			
		5:
			add_monster(monster_04, monster_pos_1, 6)
			add_monster(monster_01, monster_pos_2, 12)
			add_monster(monster_01, monster_pos_3, 9)
			
		6:
			add_monster(monster_04, monster_pos_1, 6)
			add_monster(monster_02, monster_pos_2, 10)
			
		7:
			add_monster(monster_04, monster_pos_1, 6)
			add_monster(monster_04, monster_pos_2, 9)
			add_monster(monster_01, monster_pos_3, 12)
			
		8:
			add_monster(monster_03, monster_pos_1, 12)
			add_monster(monster_01, monster_pos_2, 8)
			
		9:
			add_monster(monster_03, monster_pos_1, 12)
			add_monster(monster_02, monster_pos_2, 8)
			
		10:
			add_monster(monster_03, monster_pos_1, 12)
			add_monster(monster_01, monster_pos_2, 10)
			add_monster(monster_01, monster_pos_3, 8)
		_:
			add_monster(monster_03, monster_pos_1, 12)
			add_monster(monster_04, monster_pos_2, 10)
			add_monster(monster_02, monster_pos_3, 8)
	
func add_monster(type, pos, delay):
		var new_monster = type.instantiate()
		new_monster.position = Vector2(pos, 332)
		new_monster.timer_attack = delay
		new_monster.on_monster_attack.connect(_on_monster_attack)
		new_monster.on_revive_monster.connect(revive_monster)
		new_monster.on_manipulate.connect(manipulate_cards)
		monsters.push_front(new_monster)
		add_child(new_monster)
#endregion

#region Card Effects
func activate_card(card):
	print(card)
	
	match card:
		1: # Fireball
			player.attack()
			attack_monster(get_damages_fireball(), false)
			
		2: # Magic Missile
			player.attack()
			attack_monster(get_damages_missile(), false)
			
		3: # Lightning
			player.attack()
			attack_monster(get_damages_lightning(), true)
			
		4: # Hand
			player.cast_magic()
			if (remaining_pairs > 0): process_cards(get_reveal_number())
			
		5: # Health
			player.cast_magic()
			player_health += get_hp_gain()
			if player_health > player_health_max: player_health = player_health_max
			update_player()
		
		6: # Eye
			player.cast_magic()
			reveal_cards(get_reveal_number())
			
		7: # Shield
			player.cast_magic()
			if player_shields < player_shields_max:
				player_shields += get_shields_gain()
				if player_shields > player_shields_max: player_shields = player_shields_max
				player.shield()
			update_player()
			
		8: # Coin +5
			var gain = 5
			if is_combo_power(): gain = gain * 2
			sound_coins.play()
			GameState.add_money(gain)
		
func get_damages_fireball():
	if is_combo_power() : return 10
	else : return 5
	
func get_damages_missile():
	if is_combo_power() : return 2
	else : return 1
	
func get_damages_lightning():
	if is_combo_power() : return 4
	else : return 2
	
func get_hp_gain():
	if is_combo_power() : return 2
	else : return 1
	
func get_shields_gain():
	if is_combo_power() : return 2
	else : return 1
	
func get_reveal_number():
	if is_combo_power() : return 6
	else : return 4

#endregion
