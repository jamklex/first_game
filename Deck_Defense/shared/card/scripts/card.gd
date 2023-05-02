extends Panel

class_name Card

var properties: CardProperties

# For scaling font
var LABELS = [
	"LayoutMargin/Layout/Bottom/ATK/Value", # this entry should be always visible, used for getting baseSize
	"LayoutMargin/Layout/Bottom/HP/Value",
	"Kanonenrohr/Counter",
]
var relationalScaleSize:Vector2
var baseSize:int

func _init():
	relationalScaleSize = custom_minimum_size

func initialize_new():
	initialize_from(preload("res://shared/card/scripts/properties.gd").new())

func initialize_from(card):
	properties = card
	properties.link_node(self)
	properties.reload_data()

func initialize_from_id(id):
	properties = CardProperties.of(id)
	properties.link_node(self)
	properties.reload_data()

func apply_lane_effects(my_container: HBoxContainer, my_position, enemy_container: HBoxContainer):
	properties.apply_lane_effects(my_container, my_position, enemy_container)

func apply_next_turn(my_container: HBoxContainer, my_position, enemy_container: HBoxContainer):
	properties.apply_next_turn(my_container, my_position, enemy_container)

func apply_card_laydown(my_container: HBoxContainer, my_position, enemy_container: HBoxContainer):
	properties.apply_card_laydown(my_container, my_position, enemy_container)

func can_attack(target: Card):
	return properties.can_attack(target.properties)

func prepare_attack(target: Card):
	properties.prepare_attack(target.properties)

func can_attack_directly():
	return properties.can_attack_directly()

func _resizeLabels():
	_initBaseFontSize()
	if not baseSize:
		return
	var newFontSize = int((baseSize / relationalScaleSize.y) * custom_minimum_size.y)
	for l in LABELS:
		var label = get_node(l) as Label
		if not label:
			continue
		label.add_theme_font_size_override("font_size", newFontSize)
		
func _initBaseFontSize():
	if baseSize:
		return
	var label = get_node(LABELS[0]) as Label
	if not label:
		return
	baseSize = label.get_theme_font_size("font_size")
