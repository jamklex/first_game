extends Object

var player_deck = []
var enemy_deck = []
var rng = RandomNumberGenerator.new()

var CardProperties = preload("res://scripts/obj/card-obj.gd")
var enemy_card = preload("res://prefabs/cards/card-back.tscn")
var player_card = preload("res://prefabs/cards/card.tscn")

func _ready():
	rng.randomize()

func random_cards(amount, visible):
	var array = []
	for i in range(amount):
		var card = CardProperties.new()
		card.initialize(rng.randi_range(1,7), rng.randi_range(1,7))
		array.append(card)
	return array

func create_visible_instance(card, for_player):
	var base_card = enemy_card
	if for_player:
		base_card = player_card
	var created_card = base_card.instantiate()
	created_card.initialize_from(card)
	return created_card
