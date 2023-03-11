extends Node2D

const WAIT_WHILE_FIGHT = "TurnOptions/WaitWhileFight"
const ATTACK_PLAYER = "TurnOptions/AttackOpponent"
const BLOCK_PLAYER = "TurnOptions/BlockOpponent"
enum TURN_CYCLE {
	MY_TURN,
	OPPONENT_TURN,
	FIGHT_ANIMATION
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
const ATTACK_ANIMATION_TIME = 0.1

var rng = RandomNumberGenerator.new()
var visibleCard = preload("res://prefabs/card.tscn")
var notVisibleCard = preload("res://prefabs/card-back.tscn")
var miniCard = preload("res://prefabs/card-small.tscn")
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
	playerMaxHp = 250
	playerCurrentHp = playerMaxHp
	enemyMaxHp = 250
	enemyCurrentHp = enemyMaxHp
	player_deck = random_cards(50, true)
	enemy_deck = random_cards(50, false)
	place_cards_in_hand(enemy_hand, initial_hand_cards, false)
	place_cards_in_hand(player_hand, initial_hand_cards, true)
	set_hp(enemy_healt, enemyCurrentHp, enemyMaxHp)
	set_hp(player_healt, playerCurrentHp, playerMaxHp)
	switch_to_player()

func _on_Hand_gui_input(event):
	if is_mouse_click(event) and can_place_cards():
		var node = get_node(player_hand) as HBoxContainer
		if(selected_action_card >= 0):
			bump_child_y(node.get_child(selected_action_card), bump_factor)
		selected_action_card = get_child_index(node, make_input_local(event).position, true, -1)
		if(selected_action_card >= 0):
			bump_child_y(node.get_child(selected_action_card), bump_factor*-1)

func _on_CardSpace_gui_input(event):
	if is_mouse_click(event) and can_place_cards():
		var node = get_node(player_card_space) as HBoxContainer
		var card_space_spot_selected = get_child_index(node, make_input_local(event).position, false, -1)
		if card_space_spot_selected >= 0 and selected_action_card >= 0:
			if lay_card_on_space(player_card_space, selected_action_card, card_space_spot_selected, player_hand):
				set_visibility(WAIT_WHILE_FIGHT, false)
				set_visibility(ATTACK_PLAYER, false)
				set_visibility(BLOCK_PLAYER, true)

func _on_BlockOpponent_gui_input(event):
	if is_mouse_click(event):
		switch_to_enemy()

func _on_AttackOpponent_gui_input(event):
	if is_mouse_click(event) and can_place_cards():
		current_cycle = TURN_CYCLE.FIGHT_ANIMATION
		set_visibility(WAIT_WHILE_FIGHT, true)
		set_visibility(ATTACK_PLAYER, false)
		set_visibility(BLOCK_PLAYER, false)
		player_attacks_enemy()
		switch_to_enemy()

func random_cards(amount, visible):
	var array = []
	for i in range(amount):
		var card = visibleCard.instantiate() if visible else notVisibleCard.instantiate()
		card.initialize(rng.randi_range(1,7), "test")
		array.append(card)
	return array

func enemy_move():
	var enemyHandCards = get_node(enemy_hand).get_child_count()
	var free_spots = get_free_spots(enemy_card_space)
	var will_attack = rng.randi_range(1,max_card_space_spots) > free_spots.size()
	if will_attack or (enemyHandCards == 0 and free_spots.size() < max_card_space_spots):
		await enemy_attacks_player()
	else:
		var cardsToPlay = 0 if enemyHandCards <= 0 else rng.randi_range(1, min(free_spots.size(), enemyHandCards))
		if(cardsToPlay > 0):
			for i in range(cardsToPlay):
				var spot_to_place = rng.randi_range(0, free_spots.size()-1)
				lay_card_on_space(enemy_card_space, i, free_spots[spot_to_place], enemy_hand)
				await get_tree().create_timer(CARD_DRAW_TIME).timeout
		else:
			print("enemy can't do anything...")
	switch_to_player()

func enemy_attacks_player():
	var damage_dealt = await ltr_attack(enemy_card_space, player_card_space)
	var new_hp = max(0, playerCurrentHp - damage_dealt)
	set_hp(player_healt, new_hp, playerMaxHp)
	playerCurrentHp = new_hp
	current_cycle = TURN_CYCLE.FIGHT_ANIMATION
	set_visibility(WAIT_WHILE_FIGHT, true)
	set_visibility(ATTACK_PLAYER, false)
	set_visibility(BLOCK_PLAYER, false)

func player_attacks_enemy():
	var damage_dealt = await ltr_attack(player_card_space, enemy_card_space)
	var new_hp = max(0, enemyCurrentHp - damage_dealt)
	set_hp(enemy_healt, new_hp, enemyMaxHp)
	enemyCurrentHp = new_hp

func ltr_attack(attacker, target):
	var cards_to_kill = []
	for myCard in cards_ltr_in(attacker):
		await get_tree().create_timer(ATTACK_ANIMATION_TIME).timeout
		if myCard in cards_to_kill:
			continue
		for enemyCard in cards_ltr_in(target):
			if enemyCard in cards_to_kill:
				continue
			var new_card_hp = abs(enemyCard.get_hp() - myCard.get_hp())
			if new_card_hp == 0:
				cards_to_kill.append(myCard)
				cards_to_kill.append(enemyCard)
				break
			if enemyCard.get_hp() < myCard.get_hp():
				cards_to_kill.append(enemyCard)
				myCard.set_hp(new_card_hp)
				continue
			if enemyCard.get_hp() > myCard.get_hp():
				cards_to_kill.append(myCard)
				enemyCard.set_hp(new_card_hp)
				break
	for obj in cards_to_kill:
		obj.queue_free()
	var damage_dealt = 0
	for card in cards_ltr_in(attacker):
		damage_dealt += card.get_hp()
	return damage_dealt

func cards_ltr_in(card_space_path):
	var cards = []
	var node = get_node(card_space_path) as HBoxContainer
	for child in node.get_children():
		for card in child.get_children():
			cards.append(card)
	return cards

func get_free_spots(space):
	var node = get_node(space)
	var free_spaces = []
	for child in node.get_children():
		if child.get_child_count() <= 0:
			free_spaces.append(child.get_index())
	return free_spaces

func can_place_cards():
	return current_cycle == TURN_CYCLE.MY_TURN

func switch_to_player():
	current_cycle = TURN_CYCLE.MY_TURN
	set_visibility(WAIT_WHILE_FIGHT, false)
	set_visibility(ATTACK_PLAYER, true)
	set_visibility(BLOCK_PLAYER, false)
	place_cards_in_hand(player_hand, cards_per_turn, true)
	
func switch_to_enemy():
	current_cycle = TURN_CYCLE.OPPONENT_TURN
	set_visibility(WAIT_WHILE_FIGHT, true)
	set_visibility(ATTACK_PLAYER, false)
	set_visibility(BLOCK_PLAYER, false)
	place_cards_in_hand(enemy_hand, cards_per_turn, false)
	await get_tree().create_timer(ENEMY_THINKING_TIME).timeout
	enemy_move()

func set_visibility(path, status):
	var control = get_node(path) as Control
	control.visible = status

func place_cards_in_hand(path, amount, visible):
	for n in amount:
		if get_node(path).get_child_count() == max_hand_cards:
			break
		var card = get_card_from_deck(visible)
		if card == null:
			return
		add_card_to(path, card)
		update_cards_left()
		await get_tree().create_timer(CARD_DRAW_TIME).timeout

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
	adjust_separation(hand)
	
func adjust_separation(hand):
	var card_amount = hand.get_child_count()
	var separation = 5 if card_amount <= 3 else card_amount * -10
	hand.add_theme_constant_override("separation", separation)

func set_hp(path, amount, max_amount):
	var indicator = get_node(path + "/Indicator") as Panel
	var label = get_node(path + "/Label") as Label
	label.set_text(str(amount, " / ", max_amount))
	var max_size = (get_node(path) as Panel).size[0]
	var new_size = Vector2(max_size / max_amount * amount, indicator.size[1])
	indicator.set_size(new_size)

func bump_child_y(node, increase):
	if node != null:
		node.set_position(Vector2(node.position[0], node.position[1] + increase))

func get_child_index(node, mousePosition, reversed, default_value):
	var children = node.get_children()
	if reversed:
		children.reverse()
	for child in children:
		var size = child.size
		var rect_pos = child.global_position
		var fromPos = rect_pos[0] - size[0] if reversed else rect_pos[0]
		var toPos = rect_pos[0] if reversed else rect_pos[0] + size[0]
		if is_in_range(mousePosition[0] + (size[0]*0.4 if reversed else size[0]), fromPos, toPos):
			return child.get_index()
	return default_value

func is_in_range(base_vector, from_vector, to_vector):
	return base_vector >= from_vector and base_vector <= to_vector

func is_mouse_click(event):
	return event is InputEventMouseButton and event.pressed and event.button_index == 1

func lay_card_on_space(space, from, to, hand):
	var hand_node = get_node(hand) as HBoxContainer
	var mini_card = create_mini_card(hand_node.get_child(from))
	var card_spots = get_node(space) as HBoxContainer
	var successful = add_card_to_spot(card_spots, mini_card as Panel, to)
	if successful:
		remove_card(hand_node, from)
		selected_action_card = -1
	return successful

func add_card_to_spot(spots, card, id):
	var contender = spots.get_child(id)
	if contender.get_child_count() == 0:
		contender.add_child(card)
		return true
	return false

func remove_card(node, id):
	node.remove_child(node.get_child(id))
	adjust_separation(node)

func create_mini_card(card):
	if card == null:
		return
	var mini_card = miniCard.instantiate()
	mini_card.initialize(card.get_base_hp(), card.get_description())
	return mini_card
