extends Control

const WAIT_WHILE_FIGHT = "TurnOptions/WaitWhileFight"
const ATTACK_PLAYER = "TurnOptions/AttackOpponent"
const BLOCK_PLAYER = "TurnOptions/BlockOpponent"
const player_card_space = "Player/CardSpace/Spots"
const player_healt = "Player/Health"
const player_hand = "Player/Hand"
const player_cards_left_label = "Player/CardsLeft/Amount"
const enemy_hand = "Enemy/Hand"
const enemy_healt = "Enemy/Health"
const enemy_cards_left_label = "Enemy/CardsLeft/Amount"
const enemy_card_space = "Enemy/CardSpace/Spots"

const ENEMY_THINKING_TIME = 1.5

var enemy: PlayBot
var selected_card
var bump_factor = 0.5 # 1 = full card size, 0.5 half card size

func _ready():
	get_tree().set_auto_accept_quit(true)
	initialize_game()

func initialize_game():
	GbProps.initialize()
	GbUtil.initialize(get_tree())
	enemy = PlayBot.of(GbProps.enemy_level)
	GbProps.player_hand_node = get_node(player_hand)
	GbProps.player_card_space_node = get_node(player_card_space)
	GbProps.enemy_hand_node = get_node(enemy_hand)
	GbProps.enemy_card_space_node = get_node(enemy_card_space)
	GbUtil.set_hp(get_node(enemy_healt), GbProps.enemyCurrentHp, GbProps.enemyMaxHp)
	GbUtil.set_hp(get_node(player_healt), GbProps.playerCurrentHp, GbProps.playerMaxHp)
	await place_cards_in_hand(GbProps.enemy_hand_node, GbProps.initial_hand_cards, GbProps.enemy_deck, GbProps.enemy_initial, false)
	var newPlayerCards = await place_cards_in_hand(GbProps.player_hand_node, GbProps.initial_hand_cards, GbProps.player_deck, GbProps.player_initial, true)
	setPlayerCardOnClickEvent(newPlayerCards)
	reset_hand_card_focus()
	switch_to_player()

func _on_HandCard_clicked(clickedCard:Card):
	if can_place_cards():
		var lastClickedCard = selected_card
		reset_hand_card_focus()
		if lastClickedCard != clickedCard:
			selected_card = clickedCard
			var cardHeight = selected_card.size.y
			GbUtil.bump_child_y(selected_card, cardHeight * bump_factor * -1)

func _on_CardSpace_gui_input(event):
	if GbUtil.is_mouse_click(event) and can_place_cards():
		var card_space_spot_selected = GbProps.selected_card_spot
		if card_space_spot_selected >= 0 and selected_card:
			if await GbUtil.lay_card_on_space(GbProps.player_card_space_node, selected_card, card_space_spot_selected, GbProps.player_hand_node, GbProps.enemy_card_space_node):
				GbUtil.set_visibility(get_node(WAIT_WHILE_FIGHT), false)
				GbUtil.set_visibility(get_node(ATTACK_PLAYER), false)
				GbUtil.set_visibility(get_node(BLOCK_PLAYER), true)
				reset_hand_card_focus()

func _on_BlockOpponent_gui_input(event):
	if GbUtil.is_mouse_click(event):
		reset_hand_card_focus()
		switch_to_enemy()

func _on_AttackOpponent_gui_input(event):
	if GbUtil.is_mouse_click(event) and can_place_cards() and GbUtil.count_attacking_cards(GbProps.player_card_space_node) > 0:
		reset_hand_card_focus()
		GbUtil.set_visibility(get_node(WAIT_WHILE_FIGHT), true)
		GbUtil.set_visibility(get_node(ATTACK_PLAYER), false)
		GbUtil.set_visibility(get_node(BLOCK_PLAYER), false)
		var player_cards = GbUtil.cards_ltr_in(GbProps.player_card_space_node)
		var enemy_cards = GbUtil.cards_ltr_in(GbProps.enemy_card_space_node)
		await GbUtil.attack(player_cards, enemy_cards, get_node(enemy_healt), false)
		check_winning_state()
		switch_to_enemy()

func switch_to_player():
	GbUtil.apply_next_turn_effects(GbProps.player_card_space_node, GbProps.enemy_card_space_node)
	if not check_winning_state():
		GbUtil.set_visibility(get_node(WAIT_WHILE_FIGHT), false)
		GbUtil.set_visibility(get_node(ATTACK_PLAYER), true)
		GbUtil.set_visibility(get_node(BLOCK_PLAYER), false)
		var newPlayerCards = await place_cards_in_hand(GbProps.player_hand_node, GbProps.cards_per_turn, GbProps.player_deck, GbProps.player_initial, true)
		setPlayerCardOnClickEvent(newPlayerCards)
		reset_hand_card_focus()
		GbProps.current_cycle = GbProps.TURN_CYCLE.MY_TURN

func switch_to_enemy():
	GbUtil.apply_next_turn_effects(GbProps.enemy_card_space_node, GbProps.player_card_space_node)
	if not check_winning_state():
		GbUtil.set_visibility(get_node(WAIT_WHILE_FIGHT), true)
		GbUtil.set_visibility(get_node(ATTACK_PLAYER), false)
		GbUtil.set_visibility(get_node(BLOCK_PLAYER), false)
		await place_cards_in_hand(GbProps.enemy_hand_node, GbProps.cards_per_turn, GbProps.enemy_deck, GbProps.enemy_initial, false)
		reset_hand_card_focus()
		GbProps.current_cycle = GbProps.TURN_CYCLE.OPPONENT_TURN
		enemy_move()

func enemy_move():
	var hand_cards = GbProps.enemy_hand_node
	var enemy_field_cards = GbProps.enemy_card_space_node
	var player_field_cards = GbProps.player_card_space_node
	await get_tree().create_timer(ENEMY_THINKING_TIME).timeout
	var made_move = await enemy.play_move(hand_cards, enemy_field_cards, player_field_cards, get_node(player_healt))
	if not made_move:
		print("enemy can't do anything...")
		player_wins()
	switch_to_player()

func check_winning_state():
	var enemy_cards = GbUtil.total_card_size(GbProps.enemy_deck, GbProps.enemy_card_space_node, GbProps.enemy_hand_node)
	var player_cards = GbUtil.total_card_size(GbProps.player_deck, GbProps.player_card_space_node, GbProps.player_hand_node)
	print(player_cards)
	if GbProps.enemyCurrentHp <= 0 or enemy_cards <= 0:
		player_wins()
		return true
	if GbProps.playerCurrentHp <= 0 or player_cards <= 0:
		player_looses()
		return true
	return false

func player_wins():
	GbProps.unlock(enemy.unlock_name)
	var rewardPoints = GbProps.get_enemy_win_points()
	var winEndWindow = $PlayerWins as EndWindow
	winEndWindow.setPoints(rewardPoints)
	addPlayerPoints(rewardPoints)
	GbUtil.set_visibility(get_node("PlayerWins"), true)
	GbUtil.set_visibility(get_node("Surrender"), false)
	GbProps.current_cycle = GbProps.TURN_CYCLE.GAME_END

func player_looses():
	var rewardPoints = GbProps.get_enemy_lose_points()
	var looseEndWindow = $PlayerLooses as EndWindow
	looseEndWindow.setPoints(rewardPoints)
	addPlayerPoints(rewardPoints)
	GbUtil.set_visibility(get_node("PlayerLooses"), true)
	GbUtil.set_visibility(get_node("Surrender"), false)
	GbProps.current_cycle = GbProps.TURN_CYCLE.GAME_END
	
func addPlayerPoints(rewardPoints):
	var playerData = JsonReader.read_player_data()
	var newPoints = playerData["points"]
	newPoints += rewardPoints
	playerData["points"] = newPoints
	JsonReader.save_player_data(playerData)

func can_place_cards():
	return GbProps.current_cycle == GbProps.TURN_CYCLE.MY_TURN

func place_cards_in_hand(node, amount, deck, prefered_ids, visible_card):
	var cardObjs = await GbUtil.draw_cards(node, amount, deck, prefered_ids, visible_card)
	update_cards_left()
	return cardObjs

func update_cards_left():
	var enemy = get_node(enemy_cards_left_label) as Label
	enemy.set_text(str(GbProps.enemy_deck.size()))
	var player = get_node(player_cards_left_label) as Label
	player.set_text(str(GbProps.player_deck.size()))

func reset_hand_card_focus():
	if not selected_card:
		return
	var cardHeight = selected_card.size.y
	GbUtil.bump_child_y(selected_card, cardHeight*bump_factor)
	selected_card = null
	
func setPlayerCardOnClickEvent(cards):
	for c in cards:
		var card = c as Card
		card.clicked.connect(_on_HandCard_clicked)

func _on_surrender():
	if GbProps.current_cycle != GbProps.TURN_CYCLE.GAME_END:
		get_tree().change_scene_to_file("res://scenes/menu/_main.tscn")

func _on_cancel_pressed():
	var surrenderOverlay = $surrenderOverlay as Panel
	surrenderOverlay.visible = false

func _on_show_surrender_pressed():
	var surrenderOverlay = $surrenderOverlay as Panel
	surrenderOverlay.visible = true
