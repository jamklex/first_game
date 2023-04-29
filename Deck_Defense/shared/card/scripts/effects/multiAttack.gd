class_name MultiAttackEffect

const PANEL = "MultiAttack"
const TOTAL_ATTACKS = 2

var me: CardProperties
var active = false

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("multi_attack"):
		active = card_prop_dict["multi_attack"]

func apply_attack_effect(target: CardProperties):
	if active and me.attacks_remaining > 1:
			me.direct_allowed = true

func apply_lane_effects(lane: HBoxContainer, my_pos):
	pass

func apply_effects_from_left(other: CardProperties):
	pass

func apply_effects_from_right(other: CardProperties):
	pass

func retract_effects_from_left():
	pass

func retract_effects_from_right():
	pass

func apply_next_turn(lane: HBoxContainer, my_pos):
	if active:
		me.attacks_remaining = TOTAL_ATTACKS

func apply_card_laydown(lane: HBoxContainer, my_pos):
	if active:
		me.attacks_remaining = TOTAL_ATTACKS

func reload_data():
	if active:
		me.make_visible(PANEL)
