class_name ParasiteEffect

const PANEL = "Parasite"
const INFESTED_COLOR = Color("#64c67c")

var me: CardProperties
var infested: CardProperties

func name():
	return PANEL

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("parasite"):
		return card_prop_dict["parasite"]

func defend(source: CardProperties):
	reload_data()

func next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	reload_data()

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	var target = GbUtil.get_card_from_container(enemy_lane, my_pos)
	if target == null:
		await GbUtil.wait_some_time(CardProperties.kill_wait_time).timeout
		GbUtil.remove_from_game(me.node)
		return false
	infested = target.properties
	var parasite_effect = overwrite_effects_with_own(infested)
	me.set_hp(infested.hp)
	me.set_atk(infested.atk)
	reload_data()
	parasite_effect.reload_data()
	return true

func destroy():
	GbUtil.remove_from_game_without_effect_calls(infested)

func calc_placement_points(pos: int, my_field: Dictionary, opponent_field: Dictionary):
	var points = 3
	var opponent = opponent_field[pos]
	if opponent == null:
		return 0
	elif opponent.type() == KanonenrohrEffect.PANEL:
		points += 1
	elif opponent.type() == StoneEffect.PANEL:
		points += 2
	return points

func reload_data():
	me.make_visible(PANEL)
	if infested == null:
		return
	me.overwrite_color = INFESTED_COLOR
	infested.set_hp(me.hp)
	infested.set_atk(me.atk)
	me.make_visible(CardProperties.hp_label)
	me.make_visible(CardProperties.atk_label)

func overwrite_effects_with_own(infested: CardProperties):
	var parasite_effect = ParasiteEffect.new()
	parasite_effect.load_properties({"parasite": true}, infested)
	parasite_effect.infested = me
	infested.effect = parasite_effect
	return parasite_effect
