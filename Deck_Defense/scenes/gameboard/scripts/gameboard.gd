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

var GameboardUtil = preload("res://scenes/gameboard/scripts/gameboard-util.gd").new()

var rng = RandomNumberGenerator.new()
var playerMaxHp
var playerCurrentHp
var player_deck = []
var enemyMaxHp
var enemyCurrentHp
var enemy_deck = []
var max_card_space_spots = 10;
var max_hand_cards = 5;
var initial_hand_cards = 3;
var cards_per_turn = 3;
var selected_action_card = -1
var current_cycle
var bump_factor = 100;

func _ready():
	initialize_game()

func initialize_game():
	rng.randomize()
	playerMaxHp = 50
	playerCurrentHp = playerMaxHp
	enemyMaxHp = 50
	enemyCurrentHp = enemyMaxHp
	player_deck = GameboardUtil.random_cards(50, true)
	enemy_deck = GameboardUtil.random_cards(50, false)
	set_hp(enemy_healt, enemyCurrentHp, enemyMaxHp)
	set_hp(player_healt, playerCurrentHp, playerMaxHp)
	await place_cards_in_hand(enemy_hand, initial_hand_cards, false)
	await place_cards_in_hand(player_hand, initial_hand_cards, true)
	switch_to_player()

func _on_Hand_gui_input(event):
	if GameboardUtil.is_mouse_click(event) and can_place_cards():
		var node = get_node(player_hand) as HBoxContainer
		reset_hand_card_focus()
		selected_action_card = GameboardUtil.get_child_index(node, make_input_local(event).position, true, -1)
		if(selected_action_card >= 0):
			GameboardUtil.bump_child_y(node.get_child(selected_action_card), bump_factor*-1)

func _on_CardSpace_gui_input(event):
	if GameboardUtil.is_mouse_click(event) and can_place_cards():
		var node = get_node(player_card_space) as HBoxContainer
		var card_space_spot_selected = GameboardUtil.get_child_index(node, make_input_local(event).position, false, -1)
		if card_space_spot_selected >= 0 and selected_action_card >= 0:
			if GameboardUtil.lay_card_on_space(get_node(player_card_space), selected_action_card, card_space_spot_selected, get_node(player_hand)):
				set_visibility(WAIT_WHILE_FIGHT, false)
				set_visibility(ATTACK_PLAYER, false)
				set_visibility(BLOCK_PLAYER, true)
				reset_hand_card_focus()

func _on_BlockOpponent_gui_input(event):
	if GameboardUtil.is_mouse_click(event):
		reset_hand_card_focus()
		switch_to_enemy()

func _on_AttackOpponent_gui_input(event):
	if GameboardUtil.is_mouse_click(event) and can_place_cards():
		reset_hand_card_focus()
		current_cycle = TURN_CYCLE.FIGHT_ANIMATION
		set_visibility(WAIT_WHILE_FIGHT, true)
		set_visibility(ATTACK_PLAYER, false)
		set_visibility(BLOCK_PLAYER, false)
		var player_cards = GameboardUtil.cards_ltr_in(get_node(player_card_space))
		var enemy_cards = GameboardUtil.cards_ltr_in(get_node(enemy_card_space))
		var new_hp = max(0, enemyCurrentHp - await GameboardUtil.attack(player_cards, enemy_cards, get_tree()))
		set_hp(enemy_healt, new_hp, enemyMaxHp)
		enemyCurrentHp = new_hp
		switch_to_enemy()

func switch_to_player():
	if not check_winning_state():
		set_visibility(WAIT_WHILE_FIGHT, false)
		set_visibility(ATTACK_PLAYER, true)
		set_visibility(BLOCK_PLAYER, false)
		await place_cards_in_hand(player_hand, cards_per_turn, true)
		current_cycle = TURN_CYCLE.MY_TURN

func switch_to_enemy():
	if not check_winning_state():
		current_cycle = TURN_CYCLE.OPPONENT_TURN
		set_visibility(WAIT_WHILE_FIGHT, true)
		set_visibility(ATTACK_PLAYER, false)
		set_visibility(BLOCK_PLAYER, false)
		await place_cards_in_hand(enemy_hand, cards_per_turn, false)
		await get_tree().create_timer(ENEMY_THINKING_TIME).timeout
		enemy_move()

func enemy_move():
	var enemyHandCards = get_node(enemy_hand).get_child_count()
	var free_spots = GameboardUtil.get_free_spots(get_node(enemy_card_space))
	var will_attack = rng.randi_range(1,max_card_space_spots) > free_spots.size()
	if will_attack or (enemyHandCards == 0 and free_spots.size() < max_card_space_spots):
		var player_cards = GameboardUtil.cards_ltr_in(get_node(player_card_space))
		var enemy_cards = GameboardUtil.cards_ltr_in(get_node(enemy_card_space))
		var new_hp = max(0, playerCurrentHp - await GameboardUtil.attack(enemy_cards, player_cards, get_tree()))
		set_hp(player_healt, new_hp, playerMaxHp)
		playerCurrentHp = new_hp
		current_cycle = TURN_CYCLE.FIGHT_ANIMATION
		set_visibility(WAIT_WHILE_FIGHT, true)
		set_visibility(ATTACK_PLAYER, false)
		set_visibility(BLOCK_PLAYER, false)
	else:
		var cardsToPlay = 0 if enemyHandCards <= 0 else rng.randi_range(1, min(free_spots.size(), enemyHandCards))
		if(cardsToPlay > 0):
			for i in range(cardsToPlay):
				var spot_to_place = rng.randi_range(0, free_spots.size()-1)
				GameboardUtil.lay_card_on_space(get_node(enemy_card_space), i, free_spots[spot_to_place], get_node(enemy_hand))
				await get_tree().create_timer(CARD_DRAW_TIME).timeout
		else:
			print("enemy can't do anything...")
			player_wins()
	switch_to_player()

func check_winning_state():
	var enemy_cards = GameboardUtil.total_card_size(enemy_deck, get_node(enemy_card_space), get_node(enemy_hand))
	var player_cards = GameboardUtil.total_card_size(player_deck, get_node(player_card_space), get_node(player_hand))
	if enemyCurrentHp == 0 or enemy_cards == 0:
		player_wins()
		return true
	if playerCurrentHp == 0 or player_cards == 0:
		player_looses()
		return true
	return false

func player_wins():
	set_visibility("PlayerWins", true)
	current_cycle = TURN_CYCLE.GAME_END

func player_looses():
	set_visibility("PlayerLooses", true)
	current_cycle = TURN_CYCLE.GAME_END

func can_place_cards():
	return current_cycle == TURN_CYCLE.MY_TURN

func set_visibility(path, status):
	var control = get_node(path) as Control
	control.visible = status

func place_cards_in_hand(path, amount, from_player):
	for n in amount:
		if get_node(path).get_child_count() == max_hand_cards:
			break
		var card = get_card_from_deck(from_player)
		if card == null:
			return
		add_card_to(path, GameboardUtil.create_visible_instance(card, from_player))
		update_cards_left()
		await get_tree().create_timer(CARD_DRAW_TIME).timeout
	reset_hand_card_focus()

func get_card_from_deck(player):
	var deck_used = (player_deck if player else enemy_deck) as Array
	if deck_used.size() == 0:
		return
	return deck_used.pop_at(rng.randi_range(0, deck_used.size()-1))

func update_cards_left():
	var enemy = get_node(enemy_cards_left + "/Amount") as Label
	enemy.set_text(str(enemy_deck.size()))
	var player = get_node(player_cards_left + "/Amount") as Label
	player.set_text(str(player_deck.size()))

func add_card_to(path, card):
	var hand = get_node(path) as HBoxContainer
	hand.add_child(card)
	GameboardUtil.adjust_separation(hand)

func set_hp(path, amount, max_amount):
	var indicator = get_node(path + "/Indicator") as Panel
	var label = get_node(path + "/Label") as Label
	label.set_text(str(amount, " / ", max_amount))
	var max_size = (get_node(path) as Panel).size[0]
	var new_size = Vector2(max_size / max_amount * amount, indicator.size[1])
	indicator.set_size(new_size)

func reset_hand_card_focus():
	if(selected_action_card >= 0):
		GameboardUtil.bump_child_y(get_node(player_hand).get_child(selected_action_card), bump_factor)
	selected_action_card = -1
