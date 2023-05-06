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
	update_counter(1)

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	update_counter(1)

func destroy():
	pass

func reload_data():
	me.make_visible(PANEL)
	update_counter(0)

func update_counter(add: int):
	counter = counter + add
	me.set_atk(me.base_atk * counter)
	var label = me.node.get_node(LABEL) as Label
	if label == null:
		return
	if counter > 0:
		label.set_text(str(counter))
