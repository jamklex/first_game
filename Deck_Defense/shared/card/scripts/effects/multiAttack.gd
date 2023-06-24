class_name MultiAttackEffect

const PANEL = "MultiAttack"
const LABEL = "MultiAttack/Counter"
var TOTAL_ATTACKS = 2

var me: CardProperties

func name():
	return PANEL

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("multi_attack"):
		TOTAL_ATTACKS = card_prop_dict["multi_attack"]
		me.attacks_remaining = TOTAL_ATTACKS
		return true

func defend(source: CardProperties):
	pass

func next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	me.attacks_remaining = TOTAL_ATTACKS

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	me.attacks_remaining = TOTAL_ATTACKS
	return true

func destroy():
	pass

func calc_placement_points(pos: int, my_field: Dictionary, opponent_field: Dictionary):
	var points = pos / 2
	for i in range(0, pos):
		if my_field[i] != null:
			points += 1
	if opponent_field[pos] != null:
		points += 1
	return points

func reload_data():
	me.make_visible(PANEL)
	update_counter()

func update_counter():
	var label = me.node.get_node(LABEL) as Label
	if label == null:
		return
	label.set_text(str(me.attacks_remaining) + "/" + str(TOTAL_ATTACKS))
