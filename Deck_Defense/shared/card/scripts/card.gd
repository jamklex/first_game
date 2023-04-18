extends Panel

class_name Card

var properties: CardProperties

func _ready():
	pass

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

func apply_effects(my_container: HBoxContainer, my_position):
	properties.apply_effects(my_container, my_position)
	
