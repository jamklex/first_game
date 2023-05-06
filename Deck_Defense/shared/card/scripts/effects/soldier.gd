class_name SoldierEffect

const PANEL = "Soldier"
const IMAGE = "Soldier/Image"

var me: CardProperties
var left = false
var right = false

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("soldier_left"):
		left = card_prop_dict["soldier_left"]
	if card_prop_dict.has("soldier_right"):
		right = card_prop_dict["soldier_right"]
	return left or right

func attack(target: CardProperties):
	pass

func defend(source: CardProperties):
	pass

func next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	pass

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	var neighbour: Card
	if left and my_pos >= 1:
		neighbour = GbUtil.get_card_from_container(lane, my_pos-1);
	if right and my_pos+1 < GbProps.max_card_space_spots:
		neighbour = GbUtil.get_card_from_container(lane, my_pos+1);
	if neighbour != null:
		me.set_atk(me.atk + neighbour.properties.atk)

func reload_data():
	if left:
		me.make_visible(PANEL)
	if right:
		me.make_visible(PANEL)
		me.flip_image(IMAGE)
