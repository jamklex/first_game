extends Node2D

const NEXT_PLAYER = "TurnOptions/ReturnToOpponent"
const ATTACK_PLAYER = "TurnOptions/AttackOpponent"
enum TURN_CYCLE {
	MY_TURN,
	OPPONENT_TURN,
	FIGHT_ANIMATION
}
const player_card_space = "Player/CardSpace/Spots"
const player_hand = "Player/Hand"
const player_healt = "Player/Health"
const enemy_card_space = "Enemy/CardSpace/Spots"
const enemy_hand = "Enemy/Hand"
const enemy_healt = "Enemy/Health"
const damage_per_monster = 5

var rng = RandomNumberGenerator.new()
var visibleCard = preload("res://prefabs/card.tscn")
var notVisibleCard = preload("res://prefabs/card-back.tscn")
var miniCard = preload("res://prefabs/card-small.tscn")
var playerMaxHp
var playerCurrentHp
var enemyMaxHp
var enemyCurrentHp
var max_card_space_spots = 10;
var max_hand_cards = 5;
var initial_hand_cards = 3;
var cards_per_turn = 3;
var selected_action_card = -1
var current_cycle

func _ready():
	initialize_game()

func initialize_game():
	rng.randomize()
	playerMaxHp = 250
	playerCurrentHp = playerMaxHp
	enemyMaxHp = 250
	enemyCurrentHp = enemyMaxHp
	place_cards_in_hand(enemy_hand, initial_hand_cards, false)
	place_cards_in_hand(player_hand, initial_hand_cards, true)
	set_hp(enemy_healt, enemyCurrentHp, enemyMaxHp)
	set_hp(player_healt, playerCurrentHp, playerMaxHp)
	switch_to_player()

func _on_Hand_gui_input(event):
	if is_mouse_click(event) and can_place_cards():
		var node = get_node(player_hand) as HBoxContainer
		var bump_factor = 30;
		bump_child_y(node.get_child(selected_action_card), bump_factor)
		selected_action_card = get_child_index(node, make_input_local(event).position, true, -1)
		bump_child_y(node.get_child(selected_action_card), bump_factor*-1)

func _on_CardSpace_gui_input(event):
	if is_mouse_click(event) and can_place_cards():
		var node = get_node(player_card_space) as HBoxContainer
		var card_space_spot_selected = get_child_index(node, make_input_local(event).position, false, -1)
		if card_space_spot_selected >= 0 and selected_action_card >= 0:
			lay_card_on_space(player_card_space, selected_action_card, card_space_spot_selected, player_hand)

func _on_ReturnToOpponent_gui_input(event):
	if is_mouse_click(event) and can_place_cards():
		switch_to_enemy()

func _on_AttackOpponent_gui_input(event):
	if is_mouse_click(event) and can_place_cards():
		var free_spots = get_free_spots(player_card_space)
		var damage_dealt = (10 - free_spots.size()) * damage_per_monster
		var new_hp = max(0, enemyCurrentHp - damage_dealt)
		set_hp(enemy_healt, new_hp, enemyMaxHp)
		enemyCurrentHp = new_hp
		switch_to_enemy()

func enemy_move():
	var enemyHandCards = get_node(enemy_hand).get_child_count()
	var free_spots = get_free_spots(enemy_card_space)
	var will_attack = rng.randi_range(1,max_card_space_spots) > free_spots.size()
	if will_attack or (enemyHandCards == 0 and free_spots.size() < max_card_space_spots):
		var damage_dealt = (10 - free_spots.size()) * damage_per_monster
		var new_hp = max(0, playerCurrentHp - damage_dealt)
		set_hp(player_healt, new_hp, playerMaxHp)
		playerCurrentHp = new_hp
	else:
		var cardsToPlay = 0 if enemyHandCards <= 0 else rng.randi_range(1, min(free_spots.size(), enemyHandCards))
		if(cardsToPlay > 0):
			for i in range(cardsToPlay):
				var spot_to_place = rng.randi_range(0, free_spots.size()-1)
				lay_card_on_space(enemy_card_space, i, free_spots[spot_to_place], enemy_hand)
		else:
			print("enemy can't do anything...")
	switch_to_player()

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
	set_visibility(NEXT_PLAYER, false)
	set_visibility(ATTACK_PLAYER, true)
	var cards_to_max = max_hand_cards - get_node(player_hand).get_child_count()
	place_cards_in_hand(player_hand, min(cards_to_max, cards_per_turn), true)
	
func switch_to_enemy():
	current_cycle = TURN_CYCLE.OPPONENT_TURN
	set_visibility(NEXT_PLAYER, true)
	set_visibility(ATTACK_PLAYER, false)
	var cards_to_max = max_hand_cards - get_node(enemy_hand).get_child_count()
	place_cards_in_hand(enemy_hand, min(cards_to_max, cards_per_turn), false)
	enemy_move()

func set_visibility(path, status):
	var control = get_node(path) as Control
	control.visible = status

func place_cards_in_hand(path, amount, visible):
	for n in amount:
		var card = (visibleCard.instance() if visible else notVisibleCard.instance()) as Panel
		add_card_to(path, card)
		yield(get_tree().create_timer(.25), "timeout")

func add_card_to(path, card):
	var hand = get_node(path) as HBoxContainer
	hand.add_child(card)
	adjust_separation(hand)
	
func adjust_separation(hand):
	var card_amount = hand.get_child_count()
	var separation = 5 if card_amount <= 3 else card_amount * -10
	hand.add_constant_override("separation", separation)

func set_hp(path, amount, max_amount):
	var indicator = get_node(path + "/Indicator") as Panel
	var label = get_node(path + "/Label") as Label
	label.set_text(str(amount, " / ", max_amount))
	var max_size = (get_node(path) as Panel).rect_size[0]
	var new_size = Vector2(max_size / max_amount * amount, indicator.rect_size[1])
	indicator.set_size(new_size)

func bump_child_y(node, increase):
	if node != null:
		node.set_position(Vector2(node.rect_position[0], node.rect_position[1] + increase))

func get_child_index(node, mousePosition, reversed, default_value):
	var children = node.get_children()
	if reversed:
		children.invert()
	for child in children:
		var rect_size = child.rect_size
		var rect_pos = child.rect_global_position
		var fromPos = rect_pos[0] - rect_size[0] if reversed else rect_pos[0]
		var toPos = rect_pos[0] if reversed else rect_pos[0] + rect_size[0]
		if is_in_range(mousePosition[0], fromPos, toPos):
			return child.get_index()
	return default_value

func is_in_range(base_vector, from_vector, to_vector):
	return base_vector >= from_vector and base_vector <= to_vector

func is_mouse_click(event):
	return event is InputEventMouseButton and event.pressed and event.button_index == 1

func lay_card_on_space(space, from, to, hand):
	var card_spots = get_node(space) as HBoxContainer
	var successful = add_card_to_spot(card_spots, miniCard.instance() as Panel, to)
	if successful:
		remove_card(hand, from)
		selected_action_card = -1
		set_visibility(NEXT_PLAYER, true)
		set_visibility(ATTACK_PLAYER, false)

func add_card_to_spot(spots, card, id):
	var contender = spots.get_child(id)
	if contender.get_child_count() == 0:
		contender.add_child(card)
		return true
	return false

func remove_card(path, id):
	var hand = get_node(path) as HBoxContainer
	hand.remove_child(hand.get_child(id))
	adjust_separation(hand)
