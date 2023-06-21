class_name PlayBot

var rng:RandomNumberGenerator
var level

static func of(level):
	var enemy = PlayBot.new()
	enemy.level = level
	enemy.rng = GbProps.rng
	return enemy

func play_move(hand_cards, own_space, opponent_space, opponent_health):
	var enemyHandCards = hand_cards.get_child_count()
	var free_spots = GbUtil.get_free_spots(own_space)
	var will_attack = free_spots.size() < GbProps.max_card_space_spots and rng.randi_range(1,GbProps.max_card_space_spots) > free_spots.size() - (GbProps.enemy_level-1)
	if will_attack or (enemyHandCards == 0 and free_spots.size() < GbProps.max_card_space_spots):
		var player_cards = GbUtil.cards_ltr_in(opponent_space)
		var enemy_cards = GbUtil.cards_ltr_in(own_space)
		await GbUtil.attack(enemy_cards, player_cards, opponent_health, true)
	else:
		var cardsToPlay = 0 if enemyHandCards <= 0 else rng.randi_range(1, min(free_spots.size(), enemyHandCards))
		if(cardsToPlay > 0):
			for i in range(cardsToPlay):
				var spot_to_place = rng.randi_range(0, free_spots.size()-1)
				var initial_card = GbProps.enemy_hand_node.get_child(i)
				await GbUtil.lay_card_on_space(own_space, initial_card, free_spots[spot_to_place], hand_cards, opponent_space)
		else:
			return false
	return true
