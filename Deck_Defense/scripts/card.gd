extends Node

const description_label = "Bottom/Description"
const hp_label = "Bottom/HP"
const boosted_color = Color("#1e9a12")
const damaged_color = Color("#bb0c0e")
const default_color = Color("#000000")

var base_hp
var hp
var description

func _ready():
	pass

func initialize(base_hp, description):
	set_base_hp(base_hp)
	set_hp(base_hp)
	set_description(description)

func set_hp(new_hp):
	hp = new_hp
	update_label(hp_label, str(hp))

func get_hp():
	return hp

func set_base_hp(new_base_hp):
	base_hp = new_base_hp

func get_base_hp():
	return base_hp

func set_description(new_description):
	description = new_description
	update_label(description_label, description)

func get_description():
	return description

func is_damaged():
	return base_hp > hp

func is_boosted():
	return base_hp < hp

func update_label(path, value):
	var label = get_node(path) as Label
	if label == null:
		return
	label.set_text(value)
	var color = default_color
	if is_boosted():
		color = boosted_color
	if is_damaged():
		color = damaged_color
	label.set("custom_colors/font_color", color)
