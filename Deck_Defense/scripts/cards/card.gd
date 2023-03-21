extends Panel

var properties

func _ready():
	pass

func initialize_new():
	initialize_from(preload("res://scripts/obj/card-obj.gd").new())

func initialize_from(card):
	properties = card
	properties.link_node(self)
	properties.load_labels()
