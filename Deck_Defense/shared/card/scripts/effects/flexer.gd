class_name FlexerEffect

const PANEL = "Flexer"
const IMAGE = "Flexer/Left"

var left = false
var right = false
var me: CardProperties

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("flexer_left"):
		left = card_prop_dict["flexer_left"]
	if card_prop_dict.has("flexer_right"):
		right = card_prop_dict["flexer_right"]

func apply_attack_effect(target: CardProperties):
	pass

func apply_lane_effects(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	pass

func apply_effects_from_left(left_props):
	if left:
		me.set_hp(min(me.hp, me.base_hp) + min(left_props.hp, left_props.base_hp))

func apply_effects_from_right(right_props):
	if right:
		me.set_hp(me.base_hp + right_props.base_hp)

func retract_effects_from_left():
	if left:
		me.set_hp(min(me.hp, me.base_hp))

func retract_effects_from_right():
	if right:
		me.set_hp(min(me.hp, me.base_hp))

func apply_next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	pass

func apply_card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	pass

func reload_data():
	if left:
		me.make_visible(PANEL)
	if right:
		me.make_visible(PANEL)
		me.flip_image(IMAGE)
