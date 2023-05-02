class_name KanonenrohrEffect

const PANEL = "Kanonenrohr"
const LABEL = "Kanonenrohr/Counter"

var me: CardProperties
var active = false
var counter = 0

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("kanonenrohr"):
		active = card_prop_dict["kanonenrohr"]

func apply_attack_effect(target: CardProperties):
	pass

func apply_lane_effects(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	if active:
		me.set_atk(me.base_atk * counter)

func apply_effects_from_left(other: CardProperties):
	pass

func apply_effects_from_right(other: CardProperties):
	pass

func retract_effects_from_left():
	pass

func retract_effects_from_right():
	pass

func apply_next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	if active:
		counter = counter + 1

func apply_card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	if active:
		counter = counter + 1

func reload_data():
	if not active:
		return
	me.make_visible(PANEL)
	var label = me.node.get_node(LABEL) as Label
	if label == null:
		return
	if counter > 0:
		label.set_text(str(counter))
