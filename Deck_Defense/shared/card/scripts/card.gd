extends Panel

var properties

func _ready():
	pass

func initialize_new():
	initialize_from(preload("res://shared/card/scripts/properties.gd").new())

func initialize_from(card):
	properties = card
	properties.link_node(self)
	properties.reload_data()

func initialize_from_id(id):
	properties = preload("res://shared/card/scripts/properties.gd").new()
	properties.link_node(self)
	properties.load_data(id)
	properties.reload_data()
