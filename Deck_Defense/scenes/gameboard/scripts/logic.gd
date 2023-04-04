extends Node2D

const WAIT_WHILE_FIGHT = "TurnOptions/WaitWhileFight"
const ATTACK_PLAYER = "TurnOptions/AttackOpponent"
const BLOCK_PLAYER = "TurnOptions/BlockOpponent"
enum TURN_CYCLE {
	MY_TURN,
	OPPONENT_TURN,
	FIGHT_ANIMATION,
	GAME_END
}
const player_card_space = "Player/CardSpace/Spots"
const player_hand = "Player/Hand"
const player_healt = "Player/Health"
const player_cards_left = "Player/CardsLeft"
const enemy_card_space = "Enemy/CardSpace/Spots"
const enemy_hand = "Enemy/Hand"
const enemy_healt = "Enemy/Health"
const enemy_cards_left = "Enemy/CardsLeft"

const ENEMY_THINKING_TIME = 1.5
const CARD_DRAW_TIME = 0.2

var Util = preload("res://scenes/gameboard/scripts/util.gd").new()
var Properties = preload("res://scenes/gameboard/scripts/properties.gd").new()
var rng:RandomNumberGenerator = Properties.rng

var max_card_space_spots = 10;
var selected_action_card = -1
var current_cycle
var bump_factor = 100;

func _ready():
	initialize_game()

func initialize_game():
	var level = 1
	Properties.initialize(level)
	Util.initialize(get_tree(), Properties)
	set_hp(enemy_healt, Properties.enemyCurrentHp, Properties.enemyMaxHp)
	set_hp(player_healt, Properties.playerCurrentHp, Properties.playerMaxHp)
	await place_cards_in_hand(get_node(enemy_hand), Properties.initial_hand_cards, Properties.enemy_deck, Properties.enemy_initial, false)
	await place_cards_in_hand(get_node(player_hand), Properties.initial_hand_cards, Properties.player_deck, null, true)
	reset_hand_card_focus()
	switch_to_player()

func _on_Hand_gui_input(event):
	if Util.is_mouse_click(event) and can_place_cards():
		var node = get_node(player_hand) as HBoxContainer
		var old_selected = selected_action_card
		reset_hand_card_focus()
		var new_selected_card = Util.get_child_index(node, make_input_local(event).position, true, -1)
		if new_selected_card >= 0 and new_selected_card != old_selected:
			selected_action_card = new_selected_card
			Util.bump_child_y(node.get_child(selected_action_card), bump_factor*-1)

func _on_CardSpace_gui_input(event):
	if Util.is_mouse_click(event) and can_place_cards():
		var node = get_node(player_card_space) as HBoxContainer
		var card_space_spot_selected = Util.get_child_index(node, make_input_local(event).position, false, -1)
		if card_space_spot_selected >= 0 and selected_action_card >= 0:
			if Util.lay_card_on_space(get_node(player_card_space), selected_action_card, card_space_spot_selected, get_node(player_hand)):
				Util.set_visibility(get_node(WAIT_WHILE_FIGHT), false)
				Util.set_visibility(get_node(ATTACK_PLAYER), false)
				Util.set_visibility(get_node(BLOCK_PLAYER), true)
				reset_hand_card_focus()

func _on_BlockOpponent_gui_input(event):
	if Util.is_mouse_click(event):
		reset_hand_card_focus()
		switch_to_enemy()

func _on_AttackOpponent_gui_input(event):
	if Util.is_mouse_click(event) and can_place_cards():
		reset_hand_card_focus()
		current_cycle = TURN_CYCLE.FIGHT_ANIMATION
		Util.set_visibility(get_node(WAIT_WHILE_FIGHT), true)
		Util.set_visibility(get_node(ATTACK_PLAYER), false)
		Util.set_visibility(get_node(BLOCK_PLAYER), false)
		var player_cards = Util.cards_ltr_in(get_node(player_card_space))
		var enemy_cards = Util.cards_ltr_in(get_node(enemy_card_space))
		var new_hp = max(0, Properties.enemyCurrentHp - await Util.attack(player_cards, enemy_cards))
		set_hp(enemy_healt, new_hp, Properties.enemyMaxHp)
		Properties.enemyCurrentHp = new_hp
		switch_to_enemy()

func switch_to_player():
	if not check_winning_state():
		Util.set_visibility(get_node(WAIT_WHILE_FIGHT), false)
		Util.set_visibility(get_node(ATTACK_PLAYER), true)
		Util.set_visibility(get_node(BLOCK_PLAYER), false)
		await place_cards_in_hand(get_node(player_hand), Properties.cards_per_turn, Properties.player_deck, null, true)
		reset_hand_card_focus()
		current_cycle = TURN_CYCLE.MY_TURN

func switch_to_enemy():
	if not check_winning_state():
		current_cycle = TURN_CYCLE.OPPONENT_TURN
		Util.set_visibility(get_node(WAIT_WHILE_FIGHT), true)
		Util.set_visibility(get_node(ATTACK_PLAYER), false)
		Util.set_visibility(get_node(BLOCK_PLAYER), false)
		await place_cards_in_hand(get_node(enemy_hand), Properties.cards_per_turn, Properties.enemy_deck, Properties.enemy_initial, false)
		reset_hand_card_focus()
		await get_tree().create_timer(ENEMY_THINKING_TIME).timeout
		enemy_move()

func enemy_move():
	var enemyHandCards = get_node(enemy_hand).get_child_count()
	var free_spots = Util.get_free_spots(get_node(enemy_card_space))
	var will_attack = rng.randi_range(1,max_card_space_spots) > free_spots.size()
	if will_attack or (enemyHandCards == 0 and free_spots.size() < max_card_space_spots):
		var player_cards = Util.cards_ltr_in(get_node(player_card_space))
		var enemy_cards = Util.cards_ltr_in(get_node(enemy_card_space))
		var new_hp = max(0, Properties.playerCurrentHp - await Util.attack(enemy_cards, player_cards))
		set_hp(player_healt, new_hp, Properties.playerMaxHp)
		Properties.playerCurrentHp = new_hp
		current_cycle = TURN_CYCLE.FIGHT_ANIMATION
		Util.set_visibility(get_node(WAIT_WHILE_FIGHT), true)
		Util.set_visibility(get_node(ATTACK_PLAYER), false)
		Util.set_visibility(get_node(BLOCK_PLAYER), false)
	else:
		var cardsToPlay = 0 if enemyHandCards <= 0 else rng.randi_range(1, min(free_spots.size(), enemyHandCards))
		if(cardsToPlay > 0):
			for i in range(cardsToPlay):
				var spot_to_place = rng.randi_range(0, free_spots.size()-1)
				Util.lay_card_on_space(get_node(enemy_card_space), i, free_spots[spot_to_place], get_node(enemy_hand))
				await get_tree().create_timer(CARD_DRAW_TIME).timeout
		else:
			print("enemy can't do anything...")
			player_wins()
	switch_to_player()

func check_winning_state():
	var enemy_cards = Util.total_card_size(Properties.enemy_deck, get_node(enemy_card_space), get_node(enemy_hand))
	var player_cards = Util.total_card_size(Properties.player_deck, get_node(player_card_space), get_node(player_hand))
	if Properties.enemyCurrentHp == 0 or enemy_cards == 0:
		player_wins()
		return true
	if Properties.playerCurrentHp == 0 or player_cards == 0:
		player_looses()
		return true
	return false

func player_wins():
	Util.set_visibility(get_node("PlayerWins"), true)
	current_cycle = TURN_CYCLE.GAME_END

func player_looses():
	Util.set_visibility(get_node("PlayerLooses"), true)
	current_cycle = TURN_CYCLE.GAME_END

func can_place_cards():
	return current_cycle == TURN_CYCLE.MY_TURN

func place_cards_in_hand(node, amount, deck, prefered_ids, visible_card):
	await Util.draw_cards(node, amount, deck, prefered_ids, visible_card, CARD_DRAW_TIME)
	update_cards_left()

func update_cards_left():
	var enemy = get_node(enemy_cards_left + "/Amount") as Label
	enemy.set_text(str(Properties.enemy_deck.size()))
	var player = get_node(player_cards_left + "/Amount") as Label
	player.set_text(str(Properties.player_deck.size()))

func set_hp(path, amount, max_amount):
	var indicator = get_node(path + "/Indicator") as Panel
	var label = get_node(path + "/Label") as Label
	label.set_text(str(amount, " / ", max_amount))
	var max_size = (get_node(path) as Panel).size[0]
	var new_size = Vector2(max_size / max_amount * amount, indicator.size[1])
	indicator.set_size(new_size)

func reset_hand_card_focus():
	if(selected_action_card >= 0):
		Util.bump_child_y(get_node(player_hand).get_child(selected_action_card), bump_factor)
	selected_action_card = -1
