class_name PlayBot

var rng:RandomNumberGenerator
var level

static func of(level):
	var enemy = PlayBot.new()
	enemy.level = level
	enemy.rng = GbProps.rng
	return enemy

func play_move(hand_container: HBoxContainer, my_cards_container: HBoxContainer, opponent_cards_container: HBoxContainer, opponent_health_node: Node):
	var free_spots = GbUtil.get_free_spots(my_cards_container).size()
	var hand_cards_amount = hand_container.get_child_count()
	if hand_cards_amount > 0 and free_spots > 5:
		var playable_cards = cards_to_choose_from(hand_container) as Array
		var cards_to_play = min(3, playable_cards.size())
		for i in range(cards_to_play):
			var placement = best_placement(playable_cards, card_space_dict(my_cards_container), card_space_dict(opponent_cards_container))
			await place_card(my_cards_container, placement.card, placement.spot, hand_container, opponent_cards_container)
			playable_cards.remove_at(playable_cards.find(placement.card))
		return true
	if GbUtil.cards_ltr_in(my_cards_container).size() > 0:
		return await attack(my_cards_container, opponent_cards_container, opponent_health_node)
	return false

func cards_to_choose_from(hand_container: HBoxContainer):
	return GbUtil.cards_ltr_in(hand_container)

func best_placement(cards: Array, my_field: Dictionary, opponent_field: Dictionary):
	var best_placement = Placement.of(cards[0], 0)
	var placement_points = -1
	for card in cards:
		for i in my_field.keys():
			if my_field[i] != null:
				continue
			var points = card.calc_placement_points(i, my_field, opponent_field)
			if points > placement_points:
				placement_points = points
				best_placement = Placement.of(card, i)
	return best_placement

func card_space_dict(cards_container: HBoxContainer):
	var cards_space_dict: Dictionary = {}
	for i in range(cards_container.get_child_count()):
		var card = GbUtil.get_card_from_container(cards_container, i)
		cards_space_dict[i] = card
	return cards_space_dict

func place_card(my_container: HBoxContainer, card: Card, spot: int, hand_container: HBoxContainer, opponent_container: HBoxContainer):
	return await GbUtil.lay_card_on_space(my_container, card, spot, hand_container, opponent_container)

func attack(my_container: HBoxContainer, opponent_container: HBoxContainer, opponent_health_node: Node):
	return await GbUtil.attack(GbUtil.cards_ltr_in(my_container), GbUtil.cards_ltr_in(opponent_container), opponent_health_node, true)
