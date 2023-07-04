extends Node

const attack_animation_time = 0.5
const direct_attack_animation_time = 0.5
const card_draw_time = 0.2
const cardInfos = {
	MultiAttackEffect.PANEL: "This Card can attack multiple times per round.\nAt the beginning of each Round the attacks fill up again to their max.\nYou can see how often this Card is allowed to attack on the bottom right corner",
	StoneEffect.PANEL: "This Card can block incomming attacks, not matter how much damage they deal.\nAt the beginning of each Round this Counter is increased by 1 up too it's maximum.\nYou can see how many attacks this Card can block in the middle bottom.",
	KanonenrohrEffect.PANEL: "This Cards ATK will be multiplied by 1 each turn it stayed on the field.\nThis effect has a limit of 10 times.",
	AngelEffect.PANEL + "_l": "This Card will spread their HP across every ally to their left, reducing it to 1 HP for itself.\nIf there is no Card to their left, their HP stays the same.\nOnce placed this Card looses their effect.",
	AngelEffect.PANEL + "_r": "This Card will spread their HP across every ally to their right, reducing it to 1 HP for itself.\nIf there is no Card to their right, their HP stays the same.\nOnce placed this Card looses their effect.",
	FlexerEffect.PANEL + "_l": "This Cards HP will increase by the amount of their left ally.\nOnly direct left hand allies will count.\nOnce placed this Card looses their effect.",
	FlexerEffect.PANEL + "_r": "This Cards HP will increase by the amount of their right ally.\nOnly direct right hand allies will count.\nOnce placed this Card looses their effect.",
	SoldierEffect.PANEL + "_l": "This Cards ATK will increase by the amount of their left ally.\nOnly direct left hand allies will count.\nOnce placed this Card looses their effect.",
	SoldierEffect.PANEL + "_r": "This Cards ATK will increase by the amount of their right ally.\nOnly direct right hand allies will count.\nOnce placed this Card looses their effect.",
	BombEffect.PANEL: "This Card destroys every Card within a Radius of 1, including allies.",
	ParasiteEffect.PANEL: "This Card mirrors the enemy Card right in front of it.\nThis will strip every effect off of the enemy Card.\nIf either this or the enemy Card is destroyed, the other will immediatly be destroyed aswell.\nIf no enemy Card exists in front of it, this Card destroys itself."
}

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
		hand_node.remove_child(initial_card)
		adjust_separation(hand_node)
		await card.apply_card_laydown(card_spots, to, enemy_spots)
		await GbUtil.playCardTimer().timeout
		return true
	return false

func playCardTimer():
	return wait_some_time(0.2)

func wait_some_time(millis):
	return tree.create_timer(millis)

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

func attack(attacker_cards, target_cards, health_node: Node, use_player_hp: bool):
	var direct_damage = 0
	for attacker in attacker_cards:
		while attacker != null and attacker.can_attack() and not attacker.is_queued_for_deletion():
			attacker.reduce_attacks_remaining()
			var attacker_props = attacker.properties as CardProperties
			if not target_cards.is_empty():
				var defender = null
				for target in target_cards:
					if not target.is_queued_for_deletion():
						defender = target
						break
				var defender_props = defender.properties as CardProperties
				await attackAnimation(attacker, defender).finished
				defender.defend_against(attacker)
				var dmg = attacker_props.atk
				var hp = defender_props.hp
				var new_card_hp = hp - dmg
				if new_card_hp <= 0:
					remove_from_game(defender)
					target_cards.erase(defender)
				else:
					defender_props.set_hp(new_card_hp)
					defender_props.reload_data()
			else:
				await attackDirectAnimation(attacker).finished
				if(use_player_hp):
					GbProps.playerCurrentHp -= attacker_props.atk
					set_hp(health_node, GbProps.playerCurrentHp, GbProps.playerMaxHp)
				else:
					GbProps.enemyCurrentHp -= attacker_props.atk
					set_hp(health_node, GbProps.enemyCurrentHp, GbProps.enemyMaxHp)
				if GbProps.enemyCurrentHp <= 0 or GbProps.playerCurrentHp <= 0:
					return true
			attacker_props.reload_data()
	return true

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
	attackCard.z_index = 5
	defendCard.z_index = 1
	var soundPlayer = attackCard.get_node("AttackSoundPlayer") as AudioStreamPlayer
	soundPlayer.play()
	attackTween.chain().tween_property(attackCard, "global_position", stepPos, attack_animation_time*0.4)
	attackTween.chain().tween_property(attackCard, "global_position", targetPos, attack_animation_time*0.3)
	attackTween.chain().tween_property(attackCard, "global_position", startPos, attack_animation_time*0.3)
	attackTween.chain().tween_property(attackCard, "z_index", 2, 0)
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
		await destroyAnimation(card).animation_finished
		card.queue_free()

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

func cards_ltr_in(node: Node):
	var cards = []
	for i in range(node.get_child_count()):
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
	return deck.size() + GbUtil.cards_ltr_in(card_space).size() + hand.get_child_count()

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
		if visible_card:
			cardObj.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
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
	if node != null:
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

func set_hp(health_node: Node, amount, max_amount):
	var indicator = health_node.find_child("Indicator") as Panel
	var label = health_node.find_child("Label") as Label
	label.set_text(str(amount, " / ", max_amount))
	var max_size = (health_node as Panel).size[0]
	var new_size = Vector2(max_size / max_amount * amount, indicator.size[1])
	indicator.set_size(new_size)

func count_attacking_cards(node: Node):
	var count = 0
	for card in GbUtil.cards_ltr_in(node):
		if card.properties.attacks_remaining > 0:
			count += 1
	return count

func get_desc_of_effect(card: Card):
	var card_type = card.type()
	var effect = card.properties.effect
	if "left" in effect and effect.left:
		card_type += "_l"
	elif "right" in effect and effect.right:
		card_type += "_r"
	return cardInfos[card_type]
