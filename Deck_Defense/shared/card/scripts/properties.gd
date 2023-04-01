extends Object

const image = "Layout/Top/Face/Image"
const boni_left = "Layout/Top/Left/Image"
const boni_right = "Layout/Top/Right/Image"
const virus = "Layout/Boottom/Virus"
const hp_label = "Layout/Bottom/HP/Value"
const atk_label = "Layout/Bottom/ATK/Value"
const boosted_color = Color("#1e9a12")
const damaged_color = Color("#bb0c0e")
const default_color = Color("#000000")

var base_hp = 0
var hp = 0
var base_atk = 0
var atk = 0
var virus_level = 3
var node

func _ready():
	pass

func initialize(init_hp, init_atk):
	base_hp = init_hp
	set_hp(init_hp)
	base_atk = init_atk
	set_atk(init_atk)

func link_node(link):
	node = link

func load_labels():
	update_label(hp_label, hp, base_hp)
	update_label(atk_label, atk, base_atk)

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
