class_name MultiAttackEffect

const PANEL = "MultiAttack"
var TOTAL_ATTACKS = 2

var me: CardProperties

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("multi_attack"):
		TOTAL_ATTACKS = card_prop_dict["multi_attack"]
		return true

func defend(source: CardProperties):
	pass

func next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	me.attacks_remaining = TOTAL_ATTACKS

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	me.attacks_remaining = TOTAL_ATTACKS

func destroy():
	pass

func reload_data():
	me.make_visible(PANEL)
