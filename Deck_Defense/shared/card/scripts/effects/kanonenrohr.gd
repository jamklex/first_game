class_name KanonenrohrEffect

const PANEL = "Kanonenrohr"
const LABEL = "Kanonenrohr/Counter"

var me: CardProperties
var counter = 0
var max_counter = 0

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("kanonenrohr"):
		max_counter = 10
		return card_prop_dict["kanonenrohr"]

func defend(source: CardProperties):
	pass

func next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	update_counter(1)

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	update_counter(1)
	return true

func destroy():
	pass

func calc_placement_points(pos: int, my_field: Dictionary, opponent_field: Dictionary):
	var top_enemy_bonus =  2 if opponent_field[pos] != null else 0
	var left_enemy_bonus = 1 if opponent_field.has(pos-1) and opponent_field[pos-1] != null else 0
	var right_enemy_bonus = 1 if opponent_field.has(pos+1) and opponent_field[pos+1] != null else 0
	return pos * 1.5 + top_enemy_bonus + left_enemy_bonus + right_enemy_bonus

func reload_data():
	me.make_visible(PANEL)
	update_counter(0)

func update_counter(add: int):
	counter = min(counter + add, max_counter)
	me.set_atk(me.base_atk * max(1, counter))
	var label = me.node.get_node(LABEL) as Label
	if label == null:
		return
	if counter > 0:
		label.set_text(str(counter) + "x")
