class_name MultiAttackEffect

const PANEL = "MultiAttack"
const LABEL = "MultiAttack/Counter"
var TOTAL_ATTACKS = 2

var me: CardProperties

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
	var top_enemy_bonus =  2 if opponent_field[pos] != null else 0
	var left_enemy_bonus = 1 if opponent_field.has(pos-1) and opponent_field[pos-1] != null else 0
	var right_enemy_bonus = 1 if opponent_field.has(pos+1) and opponent_field[pos+1] != null else 0
	return pos + top_enemy_bonus + left_enemy_bonus + right_enemy_bonus

func reload_data():
	me.make_visible(PANEL)
	update_counter()

func update_counter():
	var label = me.node.get_node(LABEL) as Label
	if label == null:
		return
	label.set_text(str(me.attacks_remaining) + "/" + str(TOTAL_ATTACKS))
