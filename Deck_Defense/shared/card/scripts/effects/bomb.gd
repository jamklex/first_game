class_name BombEffect

const PANEL = "Bomb"
const HP = "LayoutMargin/Layout/Bottom/ATK"
const ATK = "LayoutMargin/Layout/Bottom/HP"
const KILL_WAIT_TIME = 0.2

var me: CardProperties
var radius = 1
var attack_own = true

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("bomb"):
		return card_prop_dict["bomb"]

func attack(target: CardProperties):
	pass

func defend(source: CardProperties):
	pass

func next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	pass

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	for pos in range(my_pos-radius, my_pos+radius+1):
		if pos < 0 or pos >= GbProps.max_card_space_spots:
			continue
		await GbUtil.wait_some_time(KILL_WAIT_TIME)
		GbUtil.remove_from_game(GbUtil.get_card_from_container(enemy_lane, pos))
		if attack_own and pos != my_pos:
			GbUtil.remove_from_game(GbUtil.get_card_from_container(lane, pos))
	await GbUtil.wait_some_time(KILL_WAIT_TIME)
	GbUtil.remove_from_game(GbUtil.get_card_from_container(lane, my_pos))

func reload_data():
	me.make_visible(PANEL)
	me.make_invisible(HP)
	me.make_invisible(ATK)
