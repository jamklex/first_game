extends Node

var rng = RandomNumberGenerator.new()
var playerMaxHp
var playerCurrentHp
var player_deck = []
var player_initial = []
var enemyMaxHp
var enemyCurrentHp
var enemy_deck = []
var enemy_initial = []
var enemy_level

var selected_card_spot
var player_hand_node
var player_card_space_node
var selected_action_card
var old_selected_action_card
var max_hand_cards = 5;
var initial_hand_cards = 3;
var cards_per_turn = 3;

var CardProperties = preload("res://shared/card/scripts/properties.gd")

func _ready():
	rng.randomize()

func initialize(level):
	enemy_level = level
	playerMaxHp = 50
	playerCurrentHp = playerMaxHp
	enemyMaxHp = 50
	enemyCurrentHp = enemyMaxHp
	player_deck = get_player_deck()
	player_initial = get_player_initial()
	enemy_deck = get_enemy_deck()
	enemy_initial = get_enemy_initial()

func get_player_deck():
	var array = []
	var content = JsonReader.read_player_data()
	var active_deck
	for deck in content["decks"]:
		if deck["active"] == true:
			for card in deck["cards"]:
				array.append_array(get_cards(card["id"], card["amount"]))
	return array

func get_player_initial():
	var array = []
	var content = JsonReader.read_player_data()
	array.append_array(content["initial"])
	return array

func get_enemy_deck():
	var array = []
	var content = JsonReader.read_enemy_data(enemy_level)
	var deck = content["deck"]
	for card in deck:
		array.append_array(get_cards(card["id"], card["amount"]))
	return array

func get_enemy_initial():
	var array = []
	var content = JsonReader.read_enemy_data(enemy_level)
	array.append_array(content["initial"])
	return array

func get_cards(id, amount):
	var array = []
	for i in range(amount):
		var card = CardProperties.new()
		card.load_data(id)
		array.append(card)
	return array
