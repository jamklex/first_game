class_name BombEffect

const PANEL = "Bomb"

var me: CardProperties
var active = false

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("bomb"):
		active = card_prop_dict["bomb"]

func apply_attack_effect(target: CardProperties):
	pass

func apply_lane_effects(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	pass

func apply_effects_from_left(other: CardProperties):
	pass

func apply_effects_from_right(other: CardProperties):
	pass

func retract_effects_from_left():
	pass

func retract_effects_from_right():
	pass

func apply_next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	pass

func apply_card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	var destruction_range = [my_pos-1, my_pos, my_pos+1]
	for pos in destruction_range:
		if pos < 0 or pos >= GbProps.max_card_space_spots:
			continue
		var my_card = GbUtil.get_card_from_container(lane, pos) as Card
		var enemy_card = GbUtil.get_card_from_container(enemy_lane, pos) as Card
		GbUtil.remove_from_game(my_card)
		GbUtil.remove_from_game(enemy_card)

func reload_data():
	if active:
		me.make_visible(PANEL)
