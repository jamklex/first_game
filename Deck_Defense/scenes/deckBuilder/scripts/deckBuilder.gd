extends Control

var playerDataJsonPath = "res://data/player.json"
var jsonReader = preload("res://shared/scripts/json_reader.gd").new()
var deckScene:PackedScene = preload("res://scenes/deckBuilder/prefabs/deck.tscn")
var cardScene:PackedScene = preload("res://scenes/deckBuilder/prefabs/selectableCard.tscn")
var requirmentScene:PackedScene = preload("res://scenes/deckBuilder/prefabs/requirement.tscn")
var rng = RandomNumberGenerator.new()
var decks = []
var cards = []
var editDeck:Control   
var deckHolder:GridContainer
var cardHolder:GridContainer
var selectedDeck: Deck = null

var requirements = [
	["Min number of cards (10)", "minNumberOfCards"]
]
var requirementObjs = []

func minNumberOfCards(deck: Deck):
	var numberOfSelectedCards = 0
	for c in cards:
		var selectedableCard = c as SelectableCard
		if selectedableCard.selected:
			numberOfSelectedCards += 1
	if numberOfSelectedCards >= 10:
		return true
	return false


# Called when the node enters the scene tree for the first time.
func _ready():
	editDeck = $editDeck
	deckHolder = $bg/deckBg/margin/deckWrapper/center/deckHolder
	cardHolder = $editDeck/marginVertAlign/vertAlign/cardWrapper/center/cardHolder
	rng.randomize()
	_loadDecks()
	_loadRequirements()
	get_tree().set_auto_accept_quit(false)  # block normal close request
	
func _loadDecks():
	cleanDeckHolder()
	decks.clear()
	var decksData = jsonReader.read_json(playerDataJsonPath)
	for deckData in decksData["decks"]:
		var newDeck = deckScene.instantiate() as Deck
		newDeck.setDeckName(deckData["name"])
		newDeck.setOnEditButtonClicked(self, "onDeckEditBtnClicked")
		newDeck.setOnActiveCheckClicked(self, "onDeckActiveCheckClicked")
		newDeck.setOnDeleteButtonClicked(self, "onDeckDeleteBtnClicked")
		newDeck.setActive(deckData["active"])
		newDeck.cards = deckData["cards"]
		deckHolder.add_child(newDeck)
		decks.append(newDeck)
	setDeckHolderColumns()
	
func onDeckDeleteBtnClicked(deck: Deck):
	print("delete pack with name: " + deck.name)
	decks.remove_at(decks.find(deck))
	deckHolder.remove_child(deck)
	setDeckHolderColumns()
		
func onDeckEditBtnClicked(deck: Deck):
	print("opening pack with name: " + deck.name)
	loadCards()
	activateDeckCards(deck)
	sortCards_activeFirst()
	loadCardHolder()
	setCardHolderColumns()
	editDeck.visible = true
	selectedDeck = deck
	checkRequirements()
	
func activateDeckCards(deck: Deck):
	for cardData in deck.cards:
		var cardAmount = cardData["amount"]
		var cardId = cardData["id"]
		for i in cardAmount:
			for c in cards:
				var selectedableCard = c as SelectableCard
				if selectedableCard.selected:
					continue
				if cardId == selectedableCard.getCard().properties.type_id:
					selectedableCard.setSelected(true)
					break
	
func sortCards_activeFirst():
	cleanCardHolder()
	var sortedCards = []
	### ADDS ONLY THE SELECTED CARDS
	var notSelected = []
	for c in cards:
		var selectedableCard = c as SelectableCard
		if selectedableCard.selected:
			sortedCards.append(selectedableCard)
		else:
			notSelected.append(selectedableCard)
	### ADDS THE REST
	sortedCards.append_array(notSelected)
	cards = sortedCards
	
func onDeckActiveCheckClicked(activeDeck:Deck):
	for index in decks.size():
		var deck = decks[index] as Deck
		deck.setActive(deck == activeDeck)
	_saveDecks()

func loadCards():
	var playerData = jsonReader.read_json(playerDataJsonPath)
	for cardData in playerData["cards"]:
		for i in range(cardData["amount"]):
			var newCard = cardScene.instantiate() as SelectableCard
			newCard.get_node("Card").initialize_from_id(cardData["id"])
			newCard.setOnClick(self, "onCardClicked")
			cards.append(newCard)
	loadCardHolder()

func onCardClicked():
	checkRequirements()

func _on_deck_wrapper_resized():
	pass

func _on_back_pressed():
	_beforeLeave()
	get_tree().change_scene_to_file("res://scenes/menu/_main.tscn")
	
func _beforeLeave():
	print("_beforeLeave")
	_saveDecks()

# handle close request
func _notification(what):   
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_beforeLeave()
		get_tree().quit()

func onResized():
	setDeckHolderColumns()
	setCardHolderColumns()
	
func setDeckHolderColumns():
	if not deckHolder:
		return
	var childCount = deckHolder.get_child_count()
	if childCount <= 0:
		return
	var firstDeck = deckHolder.get_child(0) as Control
	var deckWidth = firstDeck.custom_minimum_size[0]
	var currentWidth = deckHolder.get_parent_control().get_parent_control().get_rect().size.x
	currentWidth -= 30
	var columns = int(currentWidth / deckWidth)
	deckHolder.columns = columns
	# debug outputs
#	print(columns)
#	print("width cardholder: " + String.num_int64(resultCardHolder.get_rect().size.x))
#	print("width parent of cardholder: " + String.num_int64(resultCardHolder.get_parent_control().get_rect().size.x))

func setCardHolderColumns():
	if not cardHolder:
		return	
	var childCount = cardHolder.get_child_count()
	if childCount <= 0:
		return
	var firstCard = cardHolder.get_child(0) as Control
	var cardWidth = firstCard.custom_minimum_size[0]
	var currentWidth = cardHolder.get_parent_control().get_parent_control().get_rect().size.x
	currentWidth -= 30
	var columns = int(currentWidth / cardWidth)
	cardHolder.columns = columns
	# debug outputs
#	print(columns)
#	print("width cardholder: " + String.num_int64(resultCardHolder.get_rect().size.x))
#	print("width parent of cardholder: " + String.num_int64(resultCardHolder.get_parent_control().get_rect().size.x)

func onEditDeckCanceled():
	editDeck.visible = false
	selectedDeck = null
	cleanCardHolder()
	cards.clear()
	
func loadCardHolder():
	for card in cards:
		cardHolder.add_child(card)

func cleanCardHolder():
	for child in cardHolder.get_children():
		cardHolder.remove_child(child)
		
func cleanDeckHolder():
	for child in deckHolder.get_children():
		deckHolder.remove_child(child)

func onEditDeckDone():
	if checkRequirements():
		_saveSelectedCardsToDeck()
#		_loadDecks()
		onEditDeckCanceled()

func _on_new_deck_pressed():
	var newDeck = deckScene.instantiate() as Deck
	newDeck.setDeckName("New Deck")
	newDeck.setOnEditButtonClicked(self, "onDeckEditBtnClicked")
	newDeck.setOnActiveCheckClicked(self, "onDeckActiveCheckClicked")
	newDeck.setOnDeleteButtonClicked(self, "onDeckDeleteBtnClicked")
	deckHolder.add_child(newDeck)
	decks.append(newDeck)

func _loadRequirements():
	var reqHolder = $editDeck/marginVertAlign/vertAlign/requirements
	for requirement in requirements:
		var text = requirement[0]
		var newRequirmentObj = requirmentScene.instantiate() as Requirement
		requirementObjs.append(newRequirmentObj)
		reqHolder.add_child(newRequirmentObj)
		newRequirmentObj.setText(requirement[0])
	
func checkRequirements():
	if selectedDeck == null:
		return false
	for i in requirements.size():
		var requirementFunc = requirements[i][1]
		var requirementObj = requirementObjs[i] as Requirement
		var check = self.call(requirementFunc, selectedDeck)
		requirementObj.setActive(check)
		if not check:
			return false
	return true

func _saveDecks():
	var file = FileAccess.open(playerDataJsonPath, FileAccess.READ)
	var currentData = JSON.parse_string(file.get_as_text())
	file.close()
	var newDecks = []
	for d in decks:
		var newDeck = {}
		var deck = d as Deck
		newDeck["name"] = deck.getDeckName()
		newDeck["active"] = deck.active
		newDeck["cards"] = deck.cards
		newDecks.append(newDeck)
	currentData["decks"] = newDecks
	file = FileAccess.open(playerDataJsonPath, FileAccess.WRITE)
	file.store_line(JSON.stringify(currentData, "\t"))
	file.flush()
	file.close()

func _saveSelectedCardsToDeck():
	var newCards = []
	var doneIds = []
	for c in cards:
		var selectedableCard = c as SelectableCard
		if not selectedableCard.selected:
			continue
		var id = selectedableCard.getCard().properties.type_id
		if id in doneIds:
			continue
		var amount = 1
		for c1 in cards:
			var selectedableCard1 = c1 as SelectableCard
			if not selectedableCard1.selected:
				continue
			if selectedableCard == selectedableCard1:
				continue
			if id == selectedableCard1.getCard().properties.type_id:
				amount += 1
		var newCard = {}
		newCard["id"] = id
		newCard["amount"] = amount
		newCards.append(newCard)
		doneIds.append(id)
	selectedDeck.cards = newCards
