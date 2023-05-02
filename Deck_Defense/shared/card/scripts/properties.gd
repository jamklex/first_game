extends Object

class_name CardProperties

const image = "LayoutMargin/Layout/Top/Face"
const boni_left = "LayoutMargin/Layout/Top/Left/Image"
const boni_right = "LayoutMargin/Layout/Top/Right/Image"
const hp_label = "LayoutMargin/Layout/Bottom/HP/Value"
const atk_label = "LayoutMargin/Layout/Bottom/ATK/Value"

const boosted_color = Color("#1e9a12")
const damaged_color = Color("#bb0c0e")
const default_color = Color("#000000")

var CardData = "res://data/cards/cards.json"
var face
var base_hp = 0
var hp = 0
var base_atk = 0
var atk = 0
var node: Card
var type_id
var max_owned = 3
var attacks_remaining = 1
var direct_allowed = true
var effects = []

static func of(id):
	var properties = CardProperties.new()
	properties.load_data(id)
	return properties

func initialize(init_hp, init_atk):
	base_hp = init_hp
	set_hp(init_hp)
	base_atk = init_atk
	set_atk(init_atk)

func set_hp(new_hp):
	hp = new_hp
	update_label(hp_label, hp, base_hp)

func set_atk(new_atk):
	atk = new_atk
	update_label(atk_label, atk, base_atk)

func link_node(link):
	node = link

func load_data(id):
	type_id = id
	var content = JsonReader.read_json(CardData)
	for card in content:
		if card["id"] == id:
			load_properties(card)
			return

func get_possible_effects():
	var possible_effects = []
	possible_effects.append(FlexerEffect.new())
	possible_effects.append(MultiAttackEffect.new())
	possible_effects.append(SoldierEffect.new())
	possible_effects.append(AngelEffect.new())
	possible_effects.append(KanonenrohrEffect.new())
	possible_effects.append(BombEffect.new())
	return possible_effects

func load_properties(card_prop_dict: Dictionary):
	face = card_prop_dict["image"]
	max_owned = card_prop_dict["max_owned"]
	initialize(card_prop_dict["hp"], card_prop_dict["atk"])
	for effect in get_possible_effects():
		if effect.load_properties(card_prop_dict, self):
			effects.append(effect)
	reload_data()

func can_attack(target: CardProperties):
	return attacks_remaining > 0

func prepare_attack(target: CardProperties):
	attacks_remaining = attacks_remaining - 1
	direct_allowed = false
	for effect in effects:
		effect.apply_attack_effect(target)

func can_attack_directly():
	return direct_allowed

func apply_lane_effects(my_container: HBoxContainer, my_position, enemy_container: HBoxContainer):
	for effect in effects:
		effect.apply_lane_effects(my_container, my_position, enemy_container)
	if my_position > 0:
		var neighbour = my_container.get_child(my_position-1)
		if neighbour.get_child_count() > 0:
			apply_effects_from_left(neighbour.get_child(0).properties as CardProperties)
		else:
			retract_effects_from_left()
	if my_position < GbProps.max_card_space_spots - 1:
		var neighbour = my_container.get_child(my_position+1)
		if neighbour.get_child_count() > 0:
			apply_effects_from_right(neighbour.get_child(0).properties as CardProperties)
		else:
			retract_effects_from_right()
	reload_data()

func apply_next_turn(my_container: HBoxContainer, my_position, enemy_container: HBoxContainer):
	attacks_remaining = 1
	direct_allowed = true
	for effect in effects:
		effect.apply_next_turn(my_container, my_position, enemy_container)
	reload_data()

func apply_card_laydown(my_container: HBoxContainer, my_position, enemy_container: HBoxContainer):
	for effect in effects:
		effect.apply_card_laydown(my_container, my_position, enemy_container)
	reload_data()

func apply_effects_from_left(left_props):
	for effect in effects:
		effect.apply_effects_from_left(left_props)

func apply_effects_from_right(right_props):
	for effect in effects:
		effect.apply_effects_from_right(right_props)

func retract_effects_from_left():
	for effect in effects:
		effect.retract_effects_from_left()

func retract_effects_from_right():
	for effect in effects:
		effect.retract_effects_from_right()

func reload_data():
	if node != null:
		update_label(hp_label, hp, base_hp)
		update_label(atk_label, atk, base_atk)
		for effect in effects:
			effect.reload_data()
		var sprite = node.get_node(image)
		if sprite != null and face != null:
			sprite.texture = load(face)
		check_self_destroy()

func check_self_destroy():
	if hp <= 0:
		GbUtil.remove_from_game(node)

func update_label(path, value, base_value):
	if node == null:
		return
	var label = node.get_node(path) as Label
	if label == null:
		return
	label.set_text(str(value))
	var color = default_color
	if value > base_value:
		color = boosted_color
	if value < base_value:
		color = damaged_color
	label.add_theme_color_override("font_color", color)

func make_visible(path):
	var panel = get_node(path)
	if panel != null:
		panel.visible = true

func make_invisible(path):
	var panel = get_node(path)
	if panel != null:
		panel.visible = false

func flip_image(path):
	var panel = get_node(path)
	if panel != null:
		panel.flip_h = true

func get_node(path):
	if node == null:
		return
	return node.get_node(path)
