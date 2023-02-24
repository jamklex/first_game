extends Node2D

var rng = RandomNumberGenerator.new()
var visibleCard = preload("res://prefabs/card.tscn")
var notVisibleCard = preload("res://prefabs/card-back.tscn")
var miniCard = preload("res://prefabs/card-small.tscn")
var playerMaxHp = rng.randi_range(75,250)
var enemyMaxHp = rng.randi_range(125,300)
var max_card_space_spots = 10;
const player_card_space = "Player/CardSpace/Spots"
const player_hand = "Player/Hand"
var selected_action_card = -1

func _ready():
	rng.randomize()
	place_cards_in_hand("Enemy/Hand", rng.randi_range(1,10), false)
	place_cards_in_hand(player_hand, rng.randi_range(1,10), true)
	set_hp("Enemy/Health", rng.randi_range(1,enemyMaxHp), enemyMaxHp)
	set_hp("Player/Health", rng.randi_range(1,playerMaxHp), playerMaxHp)

func _on_Hand_gui_input(event):
	if is_mouse_click(event):
		var hand = get_node(player_hand) as HBoxContainer
		var bump_factor = 30;
		bump_child_y(hand.get_child(selected_action_card), bump_factor)
		selected_action_card = get_card_index_in_container(hand, event)
		bump_child_y(hand.get_child(selected_action_card), bump_factor*-1)

func _on_CardSpace_gui_input(event):
	if is_mouse_click(event):
		var node = get_node(player_card_space) as HBoxContainer
		var card_space_spot_selected = get_card_index_in_container(node, event) -1
		if card_space_spot_selected > 0 and selected_action_card >= 0:
			lay_card_on_space(player_card_space, selected_action_card, card_space_spot_selected)
			selected_action_card = -1

func place_cards_in_hand(path, amount, visible):
	for n in amount:
		var card = (visibleCard.instance() if visible else notVisibleCard.instance()) as Panel
		add_card_to(path, card)

func add_card_to(path, card):
	var hand = get_node(path) as HBoxContainer
	hand.add_child(card)
	adjust_separation(hand)
	
func adjust_separation(hand):
	var separation = get_increasing_separation(hand.get_child_count())
	hand.add_constant_override("separation", separation)

func get_increasing_separation(card_amount):
	return 5 if card_amount <= 3 else card_amount * -10

func set_hp(path, amount, max_amount):
	var indicator = get_node(path + "/Indicator") as Panel
	var label = get_node(path + "/Label") as Label
	label.set_text(str(amount, " / ", max_amount))
	var max_size = (get_node(path) as Panel).rect_size[0]
	var new_size = Vector2(max_size / max_amount * amount, indicator.rect_size[1])
	indicator.set_size(new_size)

func get_card_index_in_container(node, event):
	return get_child_index(node, make_input_local(event).position, true, -1)

func bump_child_y(node, increase):
	if node != null:
		node.set_position(Vector2(node.rect_position[0], node.rect_position[1] + increase))

func get_child_index(node, position, reversed, default_value):
	var children = node.get_children()
	if reversed:
		children.invert()
	for child in children:
		var rect_size = child.rect_size
		var rect_pos = child.rect_global_position
		if is_in_range(position[0], rect_pos[0] - rect_size[0], rect_pos[0]):
			return child.get_index()
	return default_value

func is_between_vectors(base_vector, from_vector, to_vector):
	return is_in_range(base_vector[0], from_vector[0], to_vector[0]) and is_in_range(base_vector[1], from_vector[1], to_vector[1])

func is_in_range(base_vector, from_vector, to_vector):
	return base_vector >= from_vector and base_vector <= to_vector

func is_mouse_click(event):
	return event is InputEventMouseButton and event.pressed and event.button_index == 1

func lay_card_on_space(path, from, to):
	var card_spots = get_node(path) as HBoxContainer
	var available_spots = get_available_spots(path)
	if available_spots >= 1:
		remove_card("Player/Hand", from)
		add_card_to_spot(card_spots, miniCard.instance() as Panel, to)

func get_available_spots(path):
	var available = 0
	var node = get_node(path)
	for child in node.get_children():
		if child.get_child_count() == 0:
			available += 1
	return available

func add_card_to_spot(spots, card, id):
	for child in spots.get_children():
		child = child as Panel
		if id == 0:
			if child.get_child_count() > 0:
				continue
			child.add_child(card)
			return
		id -= 1
	add_card_to_spot(spots, card, 0)

func remove_card(path, id):
	var hand = get_node(path) as HBoxContainer
	for child in hand.get_children():
		if id == 0:
			hand.remove_child(child)
			break
		id -= 1
	adjust_separation(hand)
