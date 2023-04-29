extends Object

class_name CardProperties

const image = "LayoutMargin/Layout/Top/Face"
const boni_left = "LayoutMargin/Layout/Top/Left/Image"
const boni_right = "LayoutMargin/Layout/Top/Right/Image"
const hp_label = "LayoutMargin/Layout/Bottom/HP/Value"
const atk_label = "LayoutMargin/Layout/Bottom/ATK/Value"

const multi_attack_panel = "MultiAttack"
var multi_attack = false

const soldier_panel = "Soldier"
const soldier_left_image = "Soldier/Left"
var soldier_left = false
var soldier_right = false

const flexer_panel = "Flexer"
const flexer_left_image = "Flexer/Left"
var flexer_left = false
var flexer_right = false

const angel_panel = "Angel"
const angel_left_image = "Angel/Left"
var angel_left = false
var angel_right = false

const kanonenrohr_panel = "Kanonenrohr"
const kanonenrohr_counter_label = "Kanonenrohr/Counter"
var kanonenrohr = false
var kanonenrohr_counter = 0

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

static func of(id):
	var properties = preload("res://shared/card/scripts/properties.gd").new()
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

func load_properties(card_prop_dict: Dictionary):
	face = card_prop_dict["image"]
	max_owned = card_prop_dict["max_owned"]
	initialize(card_prop_dict["hp"], card_prop_dict["atk"])
	if card_prop_dict.has("multi_attack"):
		multi_attack = card_prop_dict["multi_attack"]
	if card_prop_dict.has("soldier_left"):
		soldier_left = card_prop_dict["soldier_left"]
	if card_prop_dict.has("soldier_right"):
		soldier_right = card_prop_dict["soldier_right"]
	if card_prop_dict.has("flexer_left"):
		flexer_left = card_prop_dict["flexer_left"]
	if card_prop_dict.has("flexer_right"):
		flexer_right = card_prop_dict["flexer_right"]
	if card_prop_dict.has("angel_left"):
		angel_left = card_prop_dict["angel_left"]
	if card_prop_dict.has("angel_right"):
		angel_right = card_prop_dict["angel_right"]
	if card_prop_dict.has("kanonenrohr"):
		kanonenrohr = card_prop_dict["kanonenrohr"]
	reload_data()

func apply_effects(my_container: HBoxContainer, my_position):
	if my_position > 0:
		var neighbour = my_container.get_child(my_position-1)
		if neighbour.get_child_count() > 0:
			apply_effects_from_left(neighbour.get_child(0).properties as CardProperties)
		else:
			retract_effects_from_left()
	if my_position < GameboardProperties.max_card_space_spots - 1:
		var neighbour = my_container.get_child(my_position+1)
		if neighbour.get_child_count() > 0:
			apply_effects_from_right(neighbour.get_child(0).properties as CardProperties)
		else:
			retract_effects_from_right()
	kanonenrohr_effect()
	reload_data()

func apply_next_turn(myContainer: HBoxContainer, my_position):
	kanonenrohr_count_effect()
	reload_data()

func apply_card_laydown(myContainer: HBoxContainer, my_position):
	kanonenrohr_count_effect()
	angel_effect(myContainer, my_position)
	reload_data()

func kanonenrohr_count_effect():
	if kanonenrohr:
		kanonenrohr_counter = kanonenrohr_counter + 1

func kanonenrohr_effect():
	if kanonenrohr:
		set_atk(base_atk * kanonenrohr_counter)

func angel_effect(myContainer: HBoxContainer, my_position):
	var cards: = []
	if angel_left:
		if my_position > 0:
			for i in range(my_position):
				var space = myContainer.get_child(i)
				if space.get_child_count() > 0:
					cards.append(space.get_child(0).properties)
	if angel_right:
		var spots_to_right_count = GameboardProperties.max_card_space_spots - my_position - 1
		if spots_to_right_count > 0:
			for i in range(spots_to_right_count):
				var space = myContainer.get_child(i + 1 + my_position)
				if space.get_child_count() > 0:
					cards.append(space.get_child(0).properties)
	var card_size = cards.size()
	var full_hp = 0
	var extra = 0
	if card_size > 0:
		var for_me = 1
		var hp_to_give = hp - for_me
		full_hp = floor(hp_to_give / card_size)
		extra = hp_to_give - full_hp * card_size
		set_hp(for_me)
	for props in cards:
		var additional = 0
		if extra > 0:
			extra = extra -1
			additional = 1
		props.set_hp(props.hp + full_hp + additional)

func apply_effects_from_left(left_props):
	if soldier_left:
		set_atk(min(atk, base_atk) + min(left_props.atk, left_props.base_atk))
	if flexer_left:
		set_hp(min(hp, base_hp) + min(left_props.hp, left_props.base_hp))

func retract_effects_from_left():
	if soldier_left:
		set_atk(min(atk, base_atk))
	if flexer_left:
		set_hp(min(hp, base_hp))

func apply_effects_from_right(right_props):
	if soldier_right:
		set_atk(base_atk + right_props.base_atk)
	if flexer_right:
		set_hp(base_hp + right_props.base_hp)

func retract_effects_from_right():
	if soldier_right:
		set_atk(min(atk, base_atk))
	if flexer_right:
		set_hp(min(hp, base_hp))

func reload_data():
	if node != null:
		update_label(hp_label, hp, base_hp)
		update_label(atk_label, atk, base_atk)
		if multi_attack:
			make_visible(multi_attack_panel)
		if soldier_left:
			make_visible(soldier_panel)
		if soldier_right:
			make_visible(soldier_panel)
			flip_image(soldier_left_image)
		if flexer_left:
			make_visible(flexer_panel)
		if flexer_right:
			make_visible(flexer_panel)
			flip_image(flexer_left_image)
		if angel_left:
			make_visible(angel_panel)
		if angel_right:
			make_visible(angel_panel)
			flip_image(angel_left_image)
		if kanonenrohr:
			make_visible(kanonenrohr_panel)
			var label = node.get_node(kanonenrohr_counter_label) as Label
			if label == null:
				return
			if kanonenrohr_counter > 0:
				label.set_text(str(kanonenrohr_counter))
		var sprite = node.get_node(image) # HERE
		if sprite != null and face != null:
			sprite.texture = load(face)
		check_self_destroy()

func check_self_destroy():
	if hp <= 0:
		GameboardUtil.remove_from_game(node)

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
	if node == null:
		return
	var panel = node.get_node(path)
	if panel == null:
		return
	panel.visible = true

func flip_image(path):
	if node == null:
		return
	var panel = node.get_node(path)
	if panel == null:
		return
	panel.flip_h = true
