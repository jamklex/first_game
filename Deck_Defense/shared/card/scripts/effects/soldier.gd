class_name SoldierEffect

const PANEL = "Soldier"
const IMAGE = "Soldier/Left"

var me: CardProperties
var left = false
var right = false

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("soldier_left"):
		left = card_prop_dict["soldier_left"]
	if card_prop_dict.has("soldier_right"):
		right = card_prop_dict["soldier_right"]

func apply_attack_effect(target: CardProperties):
	pass

func apply_lane_effects(lane: HBoxContainer, my_pos):
	pass

func apply_effects_from_left(other: CardProperties):
	if left:
		me.set_atk(min(me.atk, me.base_atk) + min(other.atk, other.base_atk))

func apply_effects_from_right(other: CardProperties):
	if right:
		me.set_atk(min(me.atk, me.base_atk) + min(other.atk, other.base_atk))

func retract_effects_from_left():
	if left:
		me.set_atk(min(me.atk, me.base_atk))

func retract_effects_from_right():
	if right:
		me.set_atk(min(me.atk, me.base_atk))

func apply_next_turn(lane: HBoxContainer, my_pos):
	pass

func apply_card_laydown(lane: HBoxContainer, my_pos):
	pass

func reload_data():
	if left:
		me.make_visible(PANEL)
	if right:
		me.make_visible(PANEL)
		me.flip_image(IMAGE)
