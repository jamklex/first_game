extends Object

const image = "Layout/Top/Face/Image"
const boni_left = "Layout/Top/Left/Image"
const boni_right = "Layout/Top/Right/Image"
const virus = "Layout/Boottom/Virus"
const hp_label = "Layout/Bottom/HP/Value"
const atk_label = "Layout/Bottom/ATK/Value"
const multi_attack_panel = "MultiAttack"
const virus_panel = "VirusFrame"
const boosted_color = Color("#1e9a12")
const damaged_color = Color("#bb0c0e")
const default_color = Color("#000000")

var JsonReader = preload("res://shared/scripts/json_reader.gd").new()
var CardData = "res://data/cards/cards.json"
var face
var base_hp = 0
var hp = 0
var base_atk = 0
var atk = 0
var virus_level = 3
var node
var type_id
var multi_attack = false

func load_data(id):
	type_id = id
	var content = JsonReader.read_json(CardData)
	for card in content:
		if card["id"] == id:
			load_properties(card)
			return

func load_properties(card_prop_dict: Dictionary):
	face = card_prop_dict["image"]
	initialize(card_prop_dict["hp"], card_prop_dict["atk"])
	if card_prop_dict.has("multi_attack"):
		multi_attack = card_prop_dict["multi_attack"]
	reload_data()

func initialize(init_hp, init_atk):
	base_hp = init_hp
	set_hp(init_hp)
	base_atk = init_atk
	set_atk(init_atk)

func link_node(link):
	node = link

func reload_data():
	if node != null:
		update_label(hp_label, hp, base_hp)
		update_label(atk_label, atk, base_atk)
		if multi_attack:
			make_visible(multi_attack_panel)
		var sprite = node.get_node(image)
		if sprite != null and face != null:
			sprite.texture = load(face)

func set_hp(new_hp):
	hp = new_hp
	update_label(hp_label, hp, base_hp)

func set_atk(new_atk):
	atk = new_atk
	update_label(atk_label, atk, base_atk)

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
	var panel = node.get_node(path) as Panel
	if panel == null:
		return
	panel.visible = true
