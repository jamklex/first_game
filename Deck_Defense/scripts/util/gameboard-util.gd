extends Object

var player_deck = []
var enemy_deck = []
var rng = RandomNumberGenerator.new()

var CardProperties = preload("res://scripts/obj/card-obj.gd")
var enemy_card = preload("res://prefabs/cards/card-back.tscn")
var player_card = preload("res://prefabs/cards/card.tscn")

func _ready():
	rng.randomize()

func random_cards(amount, visible):
	var array = []
	for i in range(amount):
		var card = CardProperties.new()
		card.initialize(rng.randi_range(1,7), rng.randi_range(1,7))
		array.append(card)
	return array

func lay_card_on_space(card_spots, from, to, hand_node):
	var initial_card = hand_node.get_child(from)
	var contender = card_spots.get_child(to)
	if initial_card != null and contender.get_child_count() == 0:
		var card = create_visible_instance(initial_card.properties, true)
		contender.add_child(card)
		card.scale = Vector2(0.5, 0.5)
		card.pivot_offset = Vector2(0, 10)
		hand_node.remove_child(hand_node.get_child(from))
		adjust_separation(hand_node)
		return true
	return false

func create_visible_instance(card, for_player):
	var base_card = enemy_card
	if for_player:
		base_card = player_card
	var created_card = base_card.instantiate()
	created_card.initialize_from(card)
	return created_card

func adjust_separation(hand):
	var card_amount = hand.get_child_count()
	var separation = 5 if card_amount <= 3 else card_amount * -10
	hand.add_theme_constant_override("separation", separation)

func attack(attacker_cards, target_cards, tree):
	const attack_animation_time = 0.25
	for atk in attacker_cards:
		if atk != null:
			var atk_prop = atk.properties
			await tree.create_timer(attack_animation_time).timeout
			for def in target_cards:
				if def != null:
					var def_prop = def.properties
					await tree.create_timer(attack_animation_time).timeout
					var new_card_hp = abs(def_prop.hp - atk_prop.hp)
					if new_card_hp == 0:
						remove_from_game(atk)
						remove_from_game(def)
						break
					if def_prop.hp < atk_prop.hp:
						remove_from_game(def)
						atk_prop.set_hp(new_card_hp)
					elif def_prop.hp > atk_prop.hp:
						remove_from_game(atk)
						def_prop.set_hp(new_card_hp)
						break
	return 0

func remove_from_game(card):
	if card != null:
		card.free()

func get_free_spots(node):
	var free_spaces = []
	for child in node.get_children():
		if child.get_child_count() <= 0:
			free_spaces.append(child.get_index())
	return free_spaces

func cards_ltr_in(node):
	var cards = []
	for child in node.get_children():
		for card in child.get_children():
			cards.append(card)
	return cards

func is_mouse_click(event):
	return event is InputEventMouseButton and event.pressed and event.button_index == 1

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

func bump_child_y(node, increase):
	if node != null:
		node.set_position(Vector2(node.position[0], node.position[1] + increase))
		node.z_index = 0 if increase > 0 else increase * -1

func total_card_size(deck, card_space, hand):
	return deck.size() + cards_ltr_in(card_space).size() + hand.get_child_count()
