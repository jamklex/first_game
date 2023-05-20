extends Panel

class_name Card

var properties: CardProperties

# For scaling font
const LABELS = [
	CardProperties.atk_label, # this entry should be always visible, used for getting baseSize
	CardProperties.hp_label,
	KanonenrohrEffect.LABEL,
	StoneEffect.LABEL,
]
var relationalScaleSize:Vector2
var baseSize:int
signal clicked(card:Card)

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

func apply_next_turn(my_container: HBoxContainer, my_position, enemy_container: HBoxContainer):
	properties.initiate_next_turn(my_container, my_position, enemy_container)

func apply_card_laydown(my_container: HBoxContainer, my_position, enemy_container: HBoxContainer):
	properties.react_on_card_laydown(my_container, my_position, enemy_container)

func can_attack():
	return properties.can_attack()

func reduce_attacks_remaining():
	properties.reduce_attacks_remaining()

func defend_against(source: Card):
	properties.initiate_defence(source.properties)

func can_attack_directly():
	return properties.can_attack_directly()

func execute_destroy_effects():
	return properties.execute_destroy_effects()

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

func _on_gui_input(event):
	if GbUtil.is_mouse_click(event):
		clicked.emit(self)
