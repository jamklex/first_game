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
const NEXT_PLAYER = "TurnOptions/ReturnToOpponent"
const ATTACK_PLAYER = "TurnOptions/AttackOpponent"
enum TURN_CYCLE {
	MY_TURN,
	OPPONENT_TURN,
	FIGHT_ANIMATION
}
var current_cycle = TURN_CYCLE.MY_TURN

func _ready():
	set_visibility(NEXT_PLAYER, false)
	set_visibility(ATTACK_PLAYER, true)
	rng.randomize()
	place_cards_in_hand("Enemy/Hand", rng.randi_range(1,10), false)
	place_cards_in_hand(player_hand, rng.randi_range(1,10), true)
	set_hp("Enemy/Health", rng.randi_range(1,enemyMaxHp), enemyMaxHp)
	set_hp("Player/Health", rng.randi_range(1,playerMaxHp), playerMaxHp)

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
			lay_card_on_space(player_card_space, selected_action_card, card_space_spot_selected)

func _on_ReturnToOpponent_gui_input(event):
	if is_mouse_click(event) and can_place_cards():
		current_cycle = TURN_CYCLE.OPPONENT_TURN
		# enemy is allowed to place cards or attack
		print("enemy will kill you!")

func _on_AttackOpponent_gui_input(event):
	if is_mouse_click(event) and can_place_cards():
		current_cycle = TURN_CYCLE.FIGHT_ANIMATION
		# you will now attack the enemy
		print("good luck winning with that...")

func can_place_cards():
	return current_cycle == TURN_CYCLE.MY_TURN

func set_visibility(path, status):
	var control = get_node(path) as Control
	control.visible = status

func place_cards_in_hand(path, amount, visible):
	for n in amount:
		var card = (visibleCard.instance() if visible else notVisibleCard.instance()) as Panel
		add_card_to(path, card)

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

func lay_card_on_space(path, from, to):
	var card_spots = get_node(path) as HBoxContainer
	var successful = add_card_to_spot(card_spots, miniCard.instance() as Panel, to)
	if successful:
		remove_card("Player/Hand", from)
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
