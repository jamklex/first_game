class_name FlexerEffect

const PANEL = "Flexer"
const IMAGE = "Flexer/Image"

var me: CardProperties
var left = false
var right = false

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("flexer_left"):
		left = card_prop_dict["flexer_left"]
	if card_prop_dict.has("flexer_right"):
		right = card_prop_dict["flexer_right"]
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
		me.set_hp(me.hp + neighbour.properties.hp)

func destroy():
	pass

func reload_data():
	if left:
		me.make_visible(PANEL)
	if right:
		me.make_visible(PANEL)
		me.flip_image(IMAGE)
