class_name PlayBot

const UNLOCK_PATTERN = "enemy_%s_cleared"
var rng:RandomNumberGenerator
var level
var unlock_name

static func of(level):
	var enemy = PlayBot.new()
	enemy.unlock_name = UNLOCK_PATTERN % str(level)
	enemy.level = level
	enemy.rng = GbProps.rng
	return enemy

func play_move(hand_container: HBoxContainer, my_cards_container: HBoxContainer, opponent_cards_container: HBoxContainer, opponent_health_node: Node):
	var hand_cards_amount = hand_container.get_child_count()
	var cards_that_can_attack_count = GbUtil.count_attacking_cards(my_cards_container)
	var attack_when_at_least = rng.randi_range(2, GbProps.max_card_space_spots - level)
	var attack_instead = true
	if hand_cards_amount > 0 and attack_when_at_least >= cards_that_can_attack_count:
		var playable_cards = GbUtil.cards_ltr_in(hand_container) as Array
		var field_cards_size = GbUtil.cards_ltr_in(my_cards_container).size()
		var cards_to_play = min((attack_when_at_least - field_cards_size) * level / 2, playable_cards.size())
		for i in range(cards_to_play):
			var placements_scored = placements(playable_cards, card_space_dict(my_cards_container), card_space_dict(opponent_cards_container))
			if placements_scored.values().max() < 1:
				if attack_instead and cards_that_can_attack_count > 0:
					break
				continue
			var diff = 5 - level
			var placement = choose_placement(diff, placements_scored)
			await GbUtil.lay_card_on_space(my_cards_container, placement.card, placement.spot, hand_container, opponent_cards_container)
			playable_cards.remove_at(playable_cards.find(placement.card))
			attack_instead = false
		if not attack_instead:
			return true
		if GbUtil.count_attacking_cards(my_cards_container) <= 0 && hand_cards_amount > 0:
			var random_card = hand_container.get_child(rng.randi_range(0, hand_cards_amount))
			await GbUtil.lay_card_on_space(my_cards_container, random_card, 0, hand_container, opponent_cards_container)
			return true
	return await GbUtil.attack(GbUtil.cards_ltr_in(my_cards_container), GbUtil.cards_ltr_in(opponent_cards_container), opponent_health_node, true)

func placements(cards: Array, my_field: Dictionary, opponent_field: Dictionary):
	var placements_scored = {}
	for card in cards:
		for i in my_field.keys():
			if my_field[i] == null:
				placements_scored[Placement.of(card, i)] = card.calc_placement_points(i, my_field, opponent_field)
	return placements_scored

func choose_placement(diff: int, placements_scored: Dictionary):
	var placements_to_choose = []
	var max_value = placements_scored.values().max()
	var min_value = min(max_value, max(2, max_value - diff))
	for i in placements_scored.keys():
		if placements_scored[i] >= min_value:
			placements_to_choose.append(i)
	var placement = placements_to_choose.pick_random()
	return placement

func card_space_dict(cards_container: HBoxContainer):
	var cards_space_dict: Dictionary = {}
	for i in range(cards_container.get_child_count()):
		var card = GbUtil.get_card_from_container(cards_container, i)
		cards_space_dict[i] = card
	return cards_space_dict
