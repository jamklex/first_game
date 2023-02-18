extends Node2D

var rng = RandomNumberGenerator.new()
var visibleCard = preload("res://prefabs/card.tscn")
var notVisibleCard = preload("res://prefabs/card-back.tscn")
var miniCard = preload("res://prefabs/card-small.tscn")
var playerMaxHp = rng.randi_range(75,250)
var enemyMaxHp = rng.randi_range(125,300)
var max_card_space_spots = 10;

func _ready():
	rng.randomize()
	place_cards_in_hand("Enemy/Hand", rng.randi_range(1,10), false)
	place_cards_in_hand("Player/Hand", rng.randi_range(1,10), true)
	set_hp("Enemy/Health", rng.randi_range(1,enemyMaxHp), enemyMaxHp)
	set_hp("Player/Health", rng.randi_range(1,playerMaxHp), playerMaxHp)

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

func _on_Hand_gui_input(event):
	if is_mouse_click(event):
		var hand = get_node("Player/Hand") as HBoxContainer
		var hand_cards = hand.get_child_count()
		if hand_cards > 0:
			lay_card_on_space("Player/CardSpace/Spots")

func is_mouse_click(event):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.pressed:
			return true
	return false

func lay_card_on_space(path):
	var card_spots = get_node(path) as HBoxContainer
	var available_spots = get_available_spots(path)
	if available_spots >= 1:
		remove_card("Player/Hand", 0)
		add_card_to_spot(card_spots, miniCard.instance() as Panel, 8)

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
