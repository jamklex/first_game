extends Object

var player_deck = []
var enemy_deck = []
var rng = RandomNumberGenerator.new()

var visibleCard = preload("res://prefabs/card.tscn")
var notVisibleCard = preload("res://prefabs/card-back.tscn")

func _ready():
	rng.randomize()

func random_cards(amount, visible):
	var array = []
	for i in range(amount):
		var card = visibleCard.instantiate() if visible else notVisibleCard.instantiate()
		card.initialize(rng.randi_range(1,7), "test")
		array.append(card)
	return array
