extends Node

var rng = RandomNumberGenerator.new()
var playerMaxHp
var playerCurrentHp
var player_deck = []
var enemyMaxHp
var enemyCurrentHp
var enemy_deck = []

var max_hand_cards = 5;
var initial_hand_cards = 3;
var cards_per_turn = 3;

var CardProperties = preload("res://shared/card/scripts/properties.gd")
var JsonReader = preload("res://shared/scripts/json_reader.gd").new()
var PlayerData = "res://data/player.json"
var EnemyData = "res://data/enemies/%s.json"

func _ready():
	rng.randomize()

func initialize(level):
	EnemyData = EnemyData % str(level)
	playerMaxHp = 50
	playerCurrentHp = playerMaxHp
	enemyMaxHp = 50
	enemyCurrentHp = enemyMaxHp
	player_deck = get_player_deck()
	enemy_deck = random_cards(50)

func random_cards(amount):
	var array = []
	for i in range(amount):
		var card = CardProperties.new()
		card.initialize(rng.randi_range(3,20), rng.randi_range(3,20))
		array.append(card)
	return array

func get_player_deck():
	var array = []
	var content: Dictionary = JsonReader.read_json(PlayerData)
	var active_deck = get_active_deck(content)
	for i in active_deck:
		array.append_array(get_cards(i["id"], i["amount"]))
	return array

func get_active_deck(dictionary):
	for i in dictionary["decks"]:
		if i["active"] == true:
			return i["cards"]

func get_cards(id, amount):
	var array = []
	for i in range(amount):
		var card = CardProperties.new()
		card.load_data(id)
		array.append(card)
	return array

func get_enemy_deck(level):
	var array = []
	return array
