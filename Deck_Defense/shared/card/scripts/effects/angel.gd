class_name AngelEffect

const PANEL = "Angel"
const IMAGE = "Angel/Image"

var me: CardProperties
var left = false
var right = false

func name():
	return PANEL

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("angel_left"):
		left = card_prop_dict["angel_left"]
	if card_prop_dict.has("angel_right"):
		right = card_prop_dict["angel_right"]
	return left or right

func defend(source: CardProperties):
	pass

func next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	pass

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	var cards = []
	var range = []
	if left and my_pos > 0:
		range = range(my_pos)
	if right and my_pos < GbProps.max_card_space_spots-1:
		range = range(my_pos+1, GbProps.max_card_space_spots)
	for i in range:
		add_card(cards, lane, i)
	var card_size = cards.size()
	if card_size <= 0:
		return
	var full_hp = 0
	var extra = 0
	var for_me = 1
	var hp_to_give = me.hp - for_me
	full_hp = floor(hp_to_give / card_size)
	extra = hp_to_give - full_hp * card_size
	me.set_hp(for_me)
	for props in cards:
		var additional = 0
		if extra > 0:
			extra = extra -1
			additional = 1
		props.set_hp(props.hp + full_hp + additional)
		props.reload_data()
	return true

func destroy():
	return true

func calc_placement_points(pos: int, my_field: Dictionary, opponent_field: Dictionary):
	var points = 1
	var start = 0 if left else pos
	var end = pos if left else GbProps.max_card_space_spots
	for i in range(start, end):
		if my_field[i] != null:
			points += 1
		else:
			points -= 0.5
	return points

func reload_data():
	if left:
		me.make_visible(PANEL)
	if right:
		me.make_visible(PANEL)
		me.flip_image(IMAGE)

func add_card(set, container, index):
	var card = GbUtil.get_card_from_container(container, index)
	if card != null:
		if card.type() == StoneEffect.PANEL:
			return
		set.append(card.properties)
