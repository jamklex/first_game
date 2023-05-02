extends Control

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

var rng:RandomNumberGenerator = GbProps.rng

var selected_action_card = -1
var current_cycle
var bump_factor = 0.5 # 1 = full card size, 0.5 half card size

func _ready():
	get_tree().set_auto_accept_quit(true)
	initialize_game()

func initialize_game():
	var level = 1
	GbProps.initialize(level)
	GbUtil.initialize(get_tree())
	GbProps.player_hand_node = get_node(player_hand)
	GbProps.player_card_space_node = get_node(player_card_space)
	GbProps.enemy_hand_node = get_node(enemy_hand)
	GbProps.enemy_card_space_node = get_node(enemy_card_space)
	set_hp(enemy_healt, GbProps.enemyCurrentHp, GbProps.enemyMaxHp)
	set_hp(player_healt, GbProps.playerCurrentHp, GbProps.playerMaxHp)
	await place_cards_in_hand(GbProps.enemy_hand_node, GbProps.initial_hand_cards, GbProps.enemy_deck, GbProps.enemy_initial, false)
	await place_cards_in_hand(GbProps.player_hand_node, GbProps.initial_hand_cards, GbProps.player_deck, GbProps.player_initial, true)
	reset_hand_card_focus()
	switch_to_player()

func _on_Hand_gui_input(event):
	if GbUtil.is_mouse_click(event) and can_place_cards():
		var node = GbProps.player_hand_node as HBoxContainer
		var old_selected = selected_action_card
		reset_hand_card_focus()
		var new_selected_card = GbUtil.get_child_index(node, make_input_local(event).position, true, -1)
		if new_selected_card >= 0 and new_selected_card != old_selected:
			selected_action_card = new_selected_card
			var card = GbUtil.get_card_from_container(node, selected_action_card)
			var cardHeight = card.size.y
			GbUtil.bump_child_y(card, cardHeight * bump_factor * -1)

func _on_CardSpace_gui_input(event):
	if GbUtil.is_mouse_click(event) and can_place_cards():
		var card_space_spot_selected = GbProps.selected_card_spot
		if card_space_spot_selected >= 0 and selected_action_card >= 0:
			if GbUtil.lay_card_on_space(GbProps.player_card_space_node, selected_action_card, card_space_spot_selected, GbProps.player_hand_node, GbProps.enemy_card_space_node):
				GbUtil.set_visibility(get_node(WAIT_WHILE_FIGHT), false)
				GbUtil.set_visibility(get_node(ATTACK_PLAYER), false)
				GbUtil.set_visibility(get_node(BLOCK_PLAYER), true)
				reset_hand_card_focus()

func _on_BlockOpponent_gui_input(event):
	if GbUtil.is_mouse_click(event):
		reset_hand_card_focus()
		switch_to_enemy()

func _on_AttackOpponent_gui_input(event):
	if GbUtil.is_mouse_click(event) and can_place_cards():
		reset_hand_card_focus()
		current_cycle = TURN_CYCLE.FIGHT_ANIMATION
		GbUtil.set_visibility(get_node(WAIT_WHILE_FIGHT), true)
		GbUtil.set_visibility(get_node(ATTACK_PLAYER), false)
		GbUtil.set_visibility(get_node(BLOCK_PLAYER), false)
		var player_cards = GbUtil.cards_ltr_in(GbProps.player_card_space_node)
		var enemy_cards = GbUtil.cards_ltr_in(GbProps.enemy_card_space_node)
		var new_hp = max(0, GbProps.enemyCurrentHp - await GbUtil.attack(player_cards, enemy_cards))
		set_hp(enemy_healt, new_hp, GbProps.enemyMaxHp)
		GbProps.enemyCurrentHp = new_hp
		switch_to_enemy()

func switch_to_player():
	GbUtil.apply_next_turn_effects(GbProps.player_card_space_node, GbProps.enemy_card_space_node)
	if not check_winning_state():
		GbUtil.set_visibility(get_node(WAIT_WHILE_FIGHT), false)
		GbUtil.set_visibility(get_node(ATTACK_PLAYER), true)
		GbUtil.set_visibility(get_node(BLOCK_PLAYER), false)
		GbUtil.apply_lane_effects(GbProps.player_card_space_node, GbProps.enemy_card_space_node)
		await place_cards_in_hand(GbProps.player_hand_node, GbProps.cards_per_turn, GbProps.player_deck, GbProps.player_initial, true)
		reset_hand_card_focus()
		current_cycle = TURN_CYCLE.MY_TURN

func switch_to_enemy():
	GbUtil.apply_next_turn_effects(GbProps.enemy_card_space_node, GbProps.player_card_space_node)
	if not check_winning_state():
		GbUtil.set_visibility(get_node(WAIT_WHILE_FIGHT), true)
		GbUtil.set_visibility(get_node(ATTACK_PLAYER), false)
		GbUtil.set_visibility(get_node(BLOCK_PLAYER), false)
		GbUtil.apply_lane_effects(GbProps.enemy_card_space_node, GbProps.player_card_space_node)
		await place_cards_in_hand(GbProps.enemy_hand_node, GbProps.cards_per_turn, GbProps.enemy_deck, GbProps.enemy_initial, false)
		reset_hand_card_focus()
		current_cycle = TURN_CYCLE.OPPONENT_TURN
		await get_tree().create_timer(ENEMY_THINKING_TIME).timeout
		enemy_move()

func enemy_move():
	var enemyHandCards = GbProps.enemy_hand_node.get_child_count()
	var free_spots = GbUtil.get_free_spots(GbProps.enemy_card_space_node)
	var will_attack = rng.randi_range(1,GbProps.max_card_space_spots) > free_spots.size()
	if will_attack or (enemyHandCards == 0 and free_spots.size() < GbProps.max_card_space_spots):
		var player_cards = GbUtil.cards_ltr_in(GbProps.player_card_space_node)
		var enemy_cards = GbUtil.cards_ltr_in(GbProps.enemy_card_space_node)
		var new_hp = max(0, GbProps.playerCurrentHp - await GbUtil.attack(enemy_cards, player_cards))
		set_hp(player_healt, new_hp, GbProps.playerMaxHp)
		GbProps.playerCurrentHp = new_hp
		current_cycle = TURN_CYCLE.FIGHT_ANIMATION
		GbUtil.set_visibility(get_node(WAIT_WHILE_FIGHT), true)
		GbUtil.set_visibility(get_node(ATTACK_PLAYER), false)
		GbUtil.set_visibility(get_node(BLOCK_PLAYER), false)
	else:
		var cardsToPlay = 0 if enemyHandCards <= 0 else rng.randi_range(1, min(free_spots.size(), enemyHandCards))
		if(cardsToPlay > 0):
			for i in range(cardsToPlay):
				var spot_to_place = rng.randi_range(0, free_spots.size()-1)
				GbUtil.lay_card_on_space(GbProps.enemy_card_space_node, i, free_spots[spot_to_place], GbProps.enemy_hand_node, GbProps.player_card_space_node)
				await get_tree().create_timer(CARD_DRAW_TIME).timeout
		else:
			print("enemy can't do anything...")
			player_wins()
	switch_to_player()

func check_winning_state():
	var enemy_cards = GbUtil.total_card_size(GbProps.enemy_deck, GbProps.enemy_card_space_node, GbProps.enemy_hand_node)
	var player_cards = GbUtil.total_card_size(GbProps.player_deck, GbProps.player_card_space_node, GbProps.player_hand_node)
	if GbProps.enemyCurrentHp == 0 or enemy_cards == 0:
		player_wins()
		return true
	if GbProps.playerCurrentHp == 0 or player_cards == 0:
		player_looses()
		return true
	return false

func player_wins():
	GbUtil.set_visibility(get_node("PlayerWins"), true)
	current_cycle = TURN_CYCLE.GAME_END

func player_looses():
	GbUtil.set_visibility(get_node("PlayerLooses"), true)
	current_cycle = TURN_CYCLE.GAME_END

func can_place_cards():
	return current_cycle == TURN_CYCLE.MY_TURN

func place_cards_in_hand(node, amount, deck, prefered_ids, visible_card):
	await GbUtil.draw_cards(node, amount, deck, prefered_ids, visible_card, CARD_DRAW_TIME)
	update_cards_left()

func update_cards_left():
	var enemy = get_node(enemy_cards_left + "/Amount") as Label
	enemy.set_text(str(GbProps.enemy_deck.size()))
	var player = get_node(player_cards_left + "/Amount") as Label
	player.set_text(str(GbProps.player_deck.size()))

func set_hp(path, amount, max_amount):
	var indicator = get_node(path + "/Indicator") as Panel
	var label = get_node(path + "/Label") as Label
	label.set_text(str(amount, " / ", max_amount))
	var max_size = (get_node(path) as Panel).size[0]
	var new_size = Vector2(max_size / max_amount * amount, indicator.size[1])
	indicator.set_size(new_size)

func reset_hand_card_focus():
	if(selected_action_card >= 0):
		var card = GbUtil.get_card_from_container(GbProps.player_hand_node, selected_action_card)
		if card == null:
			selected_action_card = -1
			return
		var cardHeight = card.size.y
		GbUtil.bump_child_y(card, cardHeight*bump_factor)
	selected_action_card = -1
