extends Node

const attack_animation_time = 0.5
const direct_attack_animation_time = 0.5
const card_draw_time = 0.2

var player_deck = []
var enemy_deck = []
var rng = GbProps.rng

var enemy_card = preload("res://shared/card/back.tscn")
var player_card = preload("res://shared/card/front.tscn")

var tree:SceneTree

func initialize(given_tree):
	tree = given_tree

func lay_card_on_space(card_spots: HBoxContainer, initial_card:Card, to, hand_node, enemy_spots: HBoxContainer):
	var contender = card_spots.get_child(to) as Panel
	if initial_card != null and contender.get_child_count() == 0:
		var card = create_visible_instance(initial_card.properties, true) as Card
		var yScaleSub = 20
		adjust_size(card, contender.size.y-yScaleSub)
		contender.add_child(card)
		cardLayDownAnimation(card)
		var xOffset = (contender.size.x - card.custom_minimum_size.x) / 2
		var yOffset = yScaleSub / 2
		card.position = Vector2(card.position.x + xOffset, card.position.y + yOffset)
		card.set_size(card.custom_minimum_size)
		card.apply_card_laydown(card_spots, to, enemy_spots)
		hand_node.remove_child(initial_card)
		adjust_separation(hand_node)
		return true
	return false

func apply_next_turn_effects(card_spots: HBoxContainer, enemy_spots: HBoxContainer):
	for spot in card_spots.get_children():
		if spot.get_child_count() > 0:
			var card = (spot.get_child(0) as Card)
			card.apply_next_turn(card_spots, spot.get_index(), enemy_spots)

func create_visible_instance(card, for_player):
	var base_card = enemy_card
	if for_player:
		base_card = player_card
	var created_card = base_card.instantiate()
	created_card.initialize_from(card)
	return created_card

func adjust_separation(hand):
	var card_amount = hand.get_child_count()
	var separation = 5 if card_amount <= 3 else card_amount * -10
	hand.add_theme_constant_override("separation", separation)

func isQueuedForDeletion(obj):
	return !weakref(obj).get_ref()

func attack(attacker_cards, target_cards):
	var direct_damage = 0
	for attacker in attacker_cards:
		while attacker != null and attacker.can_attack() and not attacker.is_queued_for_deletion():
			attacker.reduce_attacks_remaining()
			if not target_cards.is_empty():
				var defender = target_cards[0]
				if defender.is_queued_for_deletion():
					defender = target_cards[1]
				await attackAnimation(attacker, defender).finished
				defender.defend_against(attacker)
				var dmg = attacker.properties.atk
				var hp = defender.properties.hp
				var new_card_hp = hp - dmg
				if new_card_hp <= 0:
					remove_from_game(defender)
					target_cards.erase(defender)
				else:
					defender.properties.set_hp(new_card_hp)
			else:
				direct_damage += attacker.properties.atk
				await attackDirectAnimation(attacker).finished
	return direct_damage

func attackDirectAnimation(attackCard:Card):
	var attackTween = create_tween().set_parallel(true)
	var startPos = attackCard.global_position
	var stepPos = attackCard.global_position
	var size = -get_window().size.y/3
	if GbProps.current_cycle == GbProps.TURN_CYCLE.OPPONENT_TURN:
		size = abs(size)
		stepPos.y -= round(stepPos.y * 0.25)
	else:
		stepPos.y += round(stepPos.y * 0.25)
	attackCard.z_index = 3
	var targetPos = Vector2(get_window().size.x/2, startPos.y + size)
	var soundPlayer = attackCard.get_node("AttackSoundPlayer") as AudioStreamPlayer
	soundPlayer.play()
	attackTween.chain().tween_property(attackCard, "global_position", stepPos, direct_attack_animation_time*0.4)
	attackTween.chain().tween_property(attackCard, "global_position", targetPos, direct_attack_animation_time*0.3)
	attackTween.chain().tween_property(attackCard, "global_position", startPos, direct_attack_animation_time*0.3)
	attackCard.z_index = 2
	return attackTween
	
func attackAnimation(attackCard:Card, defendCard:Card):
	var attackTween = create_tween().set_parallel(true)
	var startPos = attackCard.global_position
	var targetPos = defendCard.global_position
	var stepPos = attackCard.global_position
	var size = defendCard.size.y / 2
	if startPos.y > targetPos.y:
		targetPos.y += size
		stepPos.y += round(stepPos.y * 0.1)
	else:
		targetPos.y -= size
		stepPos.y -= round(stepPos.y * 0.1)
	attackCard.z_index = 3
	defendCard.z_index = 1
	var soundPlayer = attackCard.get_node("AttackSoundPlayer") as AudioStreamPlayer
	soundPlayer.play()
	attackTween.chain().tween_property(attackCard, "global_position", stepPos, attack_animation_time*0.4)
	attackTween.chain().tween_property(attackCard, "global_position", targetPos, attack_animation_time*0.3)
	attackTween.chain().tween_property(attackCard, "global_position", startPos, attack_animation_time*0.3)
	attackCard.z_index = 2
	return attackTween

func drawAnimation():
	var drawTween = create_tween().set_parallel(true)
	drawTween.tween_interval(card_draw_time)
	return drawTween

func cardLayDownAnimation(card: Card):
	var soundPlayer = card.get_node("PlaceSoundPlayer") as AudioStreamPlayer
	soundPlayer.play()

func remove_from_game(card):
	if card != null:
		if card is CardProperties:
			card = card.node as Card
		card.execute_destroy_effects()
		remove_from_game_without_effect_calls(card)

func remove_from_game_without_effect_calls(card):
	if card != null:
		if card is CardProperties:
			card = card.node as Card
		await destroyAnimation(card).animation_finished
		card.queue_free()

func destroyAnimation(card: Card):
	var soundPlayer = card.get_node("DestroySoundPlayer") as AudioStreamPlayer
	soundPlayer.play()
	var animationPlayer = card.get_node("AnimationPlayer") as AnimationPlayer
	animationPlayer.play("Destroy")
	return animationPlayer

func get_free_spots(node):
	var free_spaces = []
	for i in range(GbProps.max_card_space_spots):
		var card = get_card_from_container(node, i)
		if card == null:
			free_spaces.append(i)
	return free_spaces

func cards_ltr_in(node):
	var cards = []
	for i in range(GbProps.max_card_space_spots):
		var card = get_card_from_container(node, i)
		if card != null:
			cards.append(card)
	return cards

func is_mouse_click(event):
	return event is InputEventMouseButton and event.pressed and event.button_index == 1

func get_child_index(node, mousePosition, reversed, default_value):
	var children = node.get_children()
	if reversed:
		children.reverse()
	for child in children:
		var size = child.size
		var rect_pos = child.global_position
		var fromPos = rect_pos[0] - size[0] if reversed else rect_pos[0]
		var toPos = rect_pos[0] if reversed else rect_pos[0] + size[0]
		if is_in_range(mousePosition[0] + (size[0]*0.4 if reversed else size[0]), fromPos, toPos):
			return child.get_index()
	return default_value

func is_in_range(base_vector, from_vector, to_vector):
	return base_vector >= from_vector and base_vector <= to_vector

func bump_child_y(node, increase):
	if node != null:
		node.set_position(Vector2(node.position[0], node.position[1] + increase))
		node.z_index = 0 if increase > 0 else increase * -1

func total_card_size(deck, card_space, hand):
	return deck.size() + cards_ltr_in(card_space).size() + hand.get_child_count()

func draw_cards(node, amount, deck, prefered_ids, visible_card):
	var cardObjs = []
	for n in amount:
		if node.get_child_count() == GbProps.max_hand_cards:
			break
		var card
		if prefered_ids != null:
			while !prefered_ids.is_empty() and card == null:
				card = get_specific_card_from_deck(deck, prefered_ids.pop_front())
		if card == null and deck.size() > 0:
			card = get_card_from_deck(deck)
		elif card == null:
			return cardObjs
		var cardObj = create_visible_instance(card, visible_card) as Card
		cardObjs.append(cardObj)
		add_card_to(node, cardObj)
		await drawAnimation().finished
	return cardObjs

func get_card_from_deck(deck):
	if deck.size() == 0:
		return
	return deck.pop_at(rng.randi_range(0, deck.size()-1))

func get_specific_card_from_deck(deck: Array, id):
	var i = 0
	for card in deck:
		if card.type_id == id:
			break
		i += 1
	return deck.pop_at(i)

func add_card_to(hand:HBoxContainer, card:Card):
	hand.add_child(card)
	adjust_separation(hand)
	adjust_size(card, hand.size.y)
	
func adjust_size(card:Card, newHeight:int):
	var sizeMultiplier = newHeight / card.custom_minimum_size.y
	var newWidth = card.custom_minimum_size.x * sizeMultiplier
	var newSize = Vector2(newWidth, newHeight)
	card.custom_minimum_size = newSize
		
func set_visibility(node, status):
	node.visible = status

func get_card_from_container(container: HBoxContainer, index: int):
	var holder = container.get_child(index)
	if holder is Card:
		return holder
	if holder == null:
		return null
	for child in holder.get_children():
		if child is Card:
			return child
		return null

func wait_some_time(time_ms):
	await tree.create_timer(time_ms).timeout
