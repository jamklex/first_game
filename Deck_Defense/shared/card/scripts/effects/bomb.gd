class_name BombEffect

const PANEL = "Bomb"

var me: CardProperties
var radius = 1
var attack_own = true

func name():
	return PANEL

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("bomb"):
		return card_prop_dict["bomb"]

func defend(source: CardProperties):
	pass

func next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	pass

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	for pos in range(my_pos-radius, my_pos+radius+1):
		if pos < 0 or pos >= GbProps.max_card_space_spots:
			continue
		await GbUtil.wait_some_time(CardProperties.kill_wait_time).timeout
		GbUtil.remove_from_game(GbUtil.get_card_from_container(enemy_lane, pos))
		if attack_own and pos != my_pos:
			GbUtil.remove_from_game(GbUtil.get_card_from_container(lane, pos))
	await GbUtil.wait_some_time(CardProperties.kill_wait_time).timeout
	GbUtil.remove_from_game(me.node)
	return true

func destroy():
	return true

func calc_placement_points(pos: int, my_field: Dictionary, opponent_field: Dictionary):
	var points = 0
	for i in range(radius):
		if (my_field.has(pos-i) and my_field[pos-i] != null):
			points -= points_for_card_type(my_field[pos-i])
		if (my_field.has(pos+i) and my_field[pos+i] != null):
			points -= points_for_card_type(my_field[pos+i])
		if (opponent_field.has(pos-i) and opponent_field[pos-i] != null):
			points += points_for_card_type(opponent_field[pos-i])
		if (opponent_field.has(pos+i) and opponent_field[pos+i] != null):
			points += points_for_card_type(opponent_field[pos+i])
	return points

func points_for_card_type(card: Card):
	var points = card.properties.atk / 20 + card.properties.hp / 20
	if card.type() == KanonenrohrEffect.PANEL:
		points += card.properties.effect.counter / 2
	elif card.type() == StoneEffect.PANEL:
		points += card.properties.effect.blocks_remaining
	return points + 1

func reload_data():
	me.make_visible(PANEL)
	me.make_invisible(CardProperties.hp_label)
	me.make_invisible(CardProperties.atk_label)
