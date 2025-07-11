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
var enemy_level = 1

var selected_card_spot = -1
var player_hand_node
var player_card_space_node
var enemy_hand_node
var enemy_card_space_node
var selected_action_card
var old_selected_action_card
var max_hand_cards = 5;
var initial_hand_cards = 3;
var cards_per_turn = 3;
var max_card_space_spots = 10;

var current_cycle
enum TURN_CYCLE {
	MY_TURN,
	OPPONENT_TURN,
	GAME_END
}

var CardProperties = preload("res://shared/card/scripts/properties.gd")
var attack_sound = preload("res://data/sounds/attack.mp3")
var kill_sound = preload("res://data/sounds/die.mp3")

func _ready():
	rng.randomize()

func initialize():
	playerMaxHp = JsonReader.read_player_data()["hp"]
	playerCurrentHp = playerMaxHp
	enemyMaxHp = JsonReader.read_enemy_data(enemy_level)["hp"]
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
				var card_amount = min(card["amount"], CardProperties.of(card["id"]).max_owned)
				array.append_array(get_cards(card["id"], card_amount))
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
		var card_amount = min(card["amount"], CardProperties.of(card["id"]).max_owned)
		array.append_array(get_cards(card["id"], card_amount))
	return array

func get_enemy_initial():
	var array = []
	var content = JsonReader.read_enemy_data(enemy_level)
	array.append_array(content["initial"])
	return array
	
func get_enemy_lose_points():
	var content = JsonReader.read_enemy_data(enemy_level)
	return int(content["losePoints"])
	
func get_enemy_win_points():
	var content = JsonReader.read_enemy_data(enemy_level)
	return int(content["winPoints"])

func get_cards(id, amount):
	var array = []
	for i in range(amount):
		var card = CardProperties.new()
		card.load_data(id)
		array.append(card)
	return array

func unlock(unlock_name):
	var player_data = JsonReader.read_player_data()
	var unlocks = player_data["unlocks"] as Array
	if not unlocks.has(unlock_name):
		unlocks.append(unlock_name)
	player_data["unlocks"] = unlocks
	JsonReader.save_player_data(player_data)
