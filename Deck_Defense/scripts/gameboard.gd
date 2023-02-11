extends Node2D

var rng = RandomNumberGenerator.new()
var visibleCard = preload("res://prefabs/card.tscn")
var notVisibleCard = preload("res://prefabs/card-back.tscn")

func _ready():
	rng.randomize()
	place_cards_in_hand("Player/Hand", rng.randi_range(1,10), true)
	place_cards_in_hand("Enemy/Hand", rng.randi_range(1,10), false)

func place_cards_in_hand(path, amount, visible):
	for n in amount:
		add_card_to(path, visibleCard.instance() if visible else notVisibleCard.instance())

func add_card_to(path, card):
	var hand = get_node(path) as HBoxContainer
	hand.add_child(card)
	var separation = get_increasing_separation(hand.get_child_count());
	hand.add_constant_override("separation", separation)
		
func get_increasing_separation(card_amount):
	return 5 if card_amount <= 3 else card_amount * -10
