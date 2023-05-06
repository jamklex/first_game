class_name KanonenrohrEffect

const PANEL = "Kanonenrohr"
const LABEL = "Kanonenrohr/Counter"

var me: CardProperties
var counter = 0

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("kanonenrohr"):
		return card_prop_dict["kanonenrohr"]

func attack(target: CardProperties):
	pass

func defend(source: CardProperties):
	pass

func next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	counter = counter + 1
	me.set_atk(me.base_atk * counter)

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	counter = counter + 1
	me.set_atk(me.base_atk * counter)

func reload_data():
	me.make_visible(PANEL)
	var label = me.node.get_node(LABEL) as Label
	if label == null:
		return
	if counter > 0:
		label.set_text(str(counter))
