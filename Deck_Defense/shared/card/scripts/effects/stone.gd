class_name StoneEffect

const PANEL = "Stone"
const LABEL = "Stone/Counter"
const MAX_HP = 99999
var MAX_BLOCKS = 3

var me: CardProperties
var blocks_remaining = 0

func load_properties(card_prop_dict: Dictionary, card: CardProperties):
	me = card
	if card_prop_dict.has("stone"):
		MAX_BLOCKS = card_prop_dict["stone"]
		blocks_remaining = MAX_BLOCKS
		return true

func defend(source: CardProperties):
	me.set_hp(me.hp + source.atk)
	update_blocks(-1)
	if blocks_remaining <= 0:
		me.set_hp(1)

func next_turn(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	me.attacks_remaining = 0
	update_blocks(1)

func card_laydown(lane: HBoxContainer, my_pos, enemy_lane: HBoxContainer):
	me.attacks_remaining = 0
	me.set_hp(1)
	me.set_atk(0)
	update_blocks(MAX_BLOCKS)

func destroy():
	pass

func reload_data():
	me.make_visible(PANEL)
	me.make_invisible(CardProperties.hp_label)
	me.make_invisible(CardProperties.atk_label)
	update_blocks(0)

func update_blocks(add: int):
	blocks_remaining = min(blocks_remaining + add, MAX_BLOCKS)
	var label = me.node.get_node(LABEL) as Label
	if label == null:
		return
	if blocks_remaining > 0:
		label.set_text(str(blocks_remaining))
