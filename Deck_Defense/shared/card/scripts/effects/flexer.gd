class_name FlexerEffect

const PANEL = "Flexer"
const IMAGE = "Flexer/Image"

var me: CardProperties
var left = false
var right = false

func name():
	return PANEL

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("flexer_left"):
		left = card_prop_dict["flexer_left"]
	if card_prop_dict.has("flexer_right"):
		right = card_prop_dict["flexer_right"]
	return left or right

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
	return true

func destroy():
	pass

func calc_placement_points(pos: int, my_field: Dictionary, opponent_field: Dictionary):
	var points = 1
	if left and my_field.has(pos-1):
		var left_friend = my_field[pos-1] as Card
		if left_friend != null:
			points += left_friend.properties.hp / 5
	if right and my_field.has(pos+1):
		var right_friend = my_field[pos+1] as Card
		if right_friend != null:
			points += right_friend.properties.hp / 5
	return points

func reload_data():
	if left:
		me.make_visible(PANEL)
	if right:
		me.make_visible(PANEL)
		me.flip_image(IMAGE)
