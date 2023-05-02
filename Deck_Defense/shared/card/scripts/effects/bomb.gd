class_name BombEffect

const PANEL = "Bomb"
const HP = "LayoutMargin/Layout/Bottom/ATK"
const ATK = "LayoutMargin/Layout/Bottom/HP"

var me: CardProperties
var active = false
var radius = 1
var attack_own = true

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
	if not active:
		return
	for pos in range(my_pos-radius, my_pos+radius+1):
		if pos < 0 or pos >= GbProps.max_card_space_spots or pos == my_pos:
			continue
		await GbUtil.wait_some_time(0.2)
		GbUtil.remove_from_game(GbUtil.get_card_from_container(enemy_lane, pos))
		if attack_own:
			GbUtil.remove_from_game(GbUtil.get_card_from_container(lane, pos))
	GbUtil.remove_from_game(GbUtil.get_card_from_container(lane, my_pos))

func reload_data():
	if not active:
		return
	me.make_visible(PANEL)
	me.make_invisible(HP)
	me.make_invisible(ATK)
