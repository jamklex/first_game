extends Panel

class_name Card

var properties: CardProperties

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
