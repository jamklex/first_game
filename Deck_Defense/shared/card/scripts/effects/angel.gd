class_name AngelEffect

const PANEL = "Angel"
const IMAGE = "Angel/Left"

var me: CardProperties
var left = false
var right = false

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("angel_left"):
		left = card_prop_dict["angel_left"]
	if card_prop_dict.has("angel_right"):
		right = card_prop_dict["angel_right"]

func apply_attack_effect(target: CardProperties):
	pass

func apply_lane_effects(lane: HBoxContainer, my_pos):
	pass

func apply_effects_from_left(other: CardProperties):
	pass

func apply_effects_from_right(other: CardProperties):
	pass

func retract_effects_from_left():
	pass

func retract_effects_from_right():
	pass

func apply_next_turn(lane: HBoxContainer, my_pos):
	pass

func apply_card_laydown(lane: HBoxContainer, my_pos):
	var cards: = []
	if left:
		if my_pos > 0:
			for i in range(my_pos):
				var space = lane.get_child(i)
				if space.get_child_count() > 0:
					cards.append(space.get_child(0).properties)
	if right:
		var spots_to_right_count = GameboardProperties.max_card_space_spots - my_pos - 1
		if spots_to_right_count > 0:
			for i in range(spots_to_right_count):
				var space = lane.get_child(i + 1 + my_pos)
				if space.get_child_count() > 0:
					cards.append(space.get_child(0).properties)
	var card_size = cards.size()
	var full_hp = 0
	var extra = 0
	if card_size > 0:
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

func reload_data():
	if left:
		me.make_visible(PANEL)
	if right:
		me.make_visible(PANEL)
		me.flip_image(IMAGE)
