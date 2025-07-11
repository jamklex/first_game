extends Control

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
var selectedCardsLabel: Label

var requirements = [
	["Min number of cards (10)", "minNumberOfCards"],
	["Max number of cards (40)", "maxNumberOfCards"]
]
var requirementObjs = []

func minNumberOfCards(deck: Deck):
	var numberOfSelectedCards = 0
	for c in cards:
		var selectedableCard = c as SelectableCard
		if selectedableCard.selected:
			numberOfSelectedCards += 1
	selectedCardsLabel.text = "Selected Cards: " + str(numberOfSelectedCards)
	if numberOfSelectedCards >= 10:
		return true
	return false
	
func maxNumberOfCards(deck: Deck):
	var numberOfSelectedCards = 0
	for c in cards:
		var selectedableCard = c as SelectableCard
		if selectedableCard.selected:
			numberOfSelectedCards += 1
	selectedCardsLabel.text = "Selected Cards: " + str(numberOfSelectedCards)
	if numberOfSelectedCards <= 40:
		return true
	return false


# Called when the node enters the scene tree for the first time.
func _ready():
	editDeck = $editDeck
	deckHolder = $bg/deckBg/margin/deckWrapper/center/deckHolder
	cardHolder = $editDeck/marginVertAlign/vertAlign/cardWrapper/center/cardHolder
	selectedCardsLabel = $editDeck/selectedCards
	rng.randomize()
	_loadDecks()
	_loadRequirements()
	get_tree().set_auto_accept_quit(false)  # block normal close request
	
func _loadDecks():
	cleanDeckHolder()
	decks.clear()
	var decksData = jsonReader.read_player_data()
	for deckData in decksData["decks"]:
		var newDeck = deckScene.instantiate() as Deck
		newDeck.setDeckName(deckData["name"])
		newDeck.setOnEditButtonClicked(self, "onDeckClicked")
		newDeck.setActive(deckData["active"])
		newDeck.cards = deckData["cards"]
		deckHolder.add_child(newDeck)
		decks.append(newDeck)
	setDeckHolderColumns()

func deleteCurrentDeck():
	if not selectedDeck:
		return
	deleteDeck(selectedDeck)

func deleteDeck(deck: Deck):
	decks.remove_at(decks.find(deck))
	deckHolder.remove_child(deck)
	setDeckHolderColumns()
		
func onDeckClicked(deck: Deck):
	loadCards()
	activateDeckCards(deck)
	sortCards_activeFirst()
	loadCardHolder()
	setCardHolderColumns()
	editDeck.visible = true
	selectedDeck = deck
	setCurrentDeckNameLabel(selectedDeck.getDeckName())
	setEditActive(selectedDeck.active)
	checkRequirements()
	
func activateDeckCards(deck: Deck):
	for cardData in deck.cards:
		var cardId = cardData["id"]
		var cardAmount = min(cardData["amount"], CardProperties.of(cardId).max_owned)
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
	
func changeActiveDeck(newActiveDeck:Deck):
	for index in decks.size():
		var deck = decks[index] as Deck
		deck.setActive(deck == newActiveDeck)
	_saveDecks()

func loadCards():
	var playerData = jsonReader.read_player_data()
	for cardData in playerData["cards"]:
		for i in range(min(cardData["amount"], CardProperties.of(cardData["id"]).max_owned)):
			var newCard = cardScene.instantiate() as SelectableCard
			newCard.get_node("Card").initialize_from_id(cardData["id"])
			newCard.click.connect(onCardClicked)
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

func onEditDeckCanceled():
	editDeck.visible = false
	selectedDeck = null
	cleanCardHolder()
	closeChangeDeckName()
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
	
func showChangeDeckName():
	switchChangeDeckNameDialog(true)
	var newDeckName = $editDeck/deckName/changeDialog/newDeckName as LineEdit
	newDeckName.text = selectedDeck.getDeckName()
	
func closeChangeDeckName():
	switchChangeDeckNameDialog(false)
	
func applyDeckName():
	var lineEdit = $editDeck/deckName/changeDialog/newDeckName as LineEdit
	var newDeckName = lineEdit.text
	if newDeckName == "":
		return
	setCurrentDeckNameLabel(newDeckName)
	selectedDeck.setDeckName(newDeckName)
	closeChangeDeckName()
	
func setCurrentDeckNameLabel(currentDeckName:String):
	var label = $editDeck/deckName/showDialog/currentDeckName as Label
	label.text = currentDeckName
	
		
func switchChangeDeckNameDialog(showChangeDialog:bool):
	var changeDialog = $editDeck/deckName/changeDialog
	var showDialog = $editDeck/deckName/showDialog
	showDialog.visible = not showChangeDialog
	changeDialog.visible = showChangeDialog
	

func _on_new_deck_pressed():
	var newDeck = deckScene.instantiate() as Deck
	newDeck.setDeckName("New Deck")
	newDeck.setOnEditButtonClicked(self, "onDeckClicked")
	deckHolder.add_child(newDeck)
	decks.append(newDeck)
	onDeckClicked(newDeck)	

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
	var currentData = jsonReader.read_player_data()
	var newDecks = []
	for d in decks:
		var newDeck = {}
		var deck = d as Deck
		newDeck["name"] = deck.getDeckName()
		newDeck["active"] = deck.active
		newDeck["cards"] = deck.cards
		newDecks.append(newDeck)
	currentData["decks"] = newDecks
	jsonReader.save_player_data(currentData)

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

func switchDeleteDialog(show:bool):
	var deleteDialog = $deleteDeckDialog as Panel
	deleteDialog.visible = show

func _on_delete_deck_pressed():
	switchDeleteDialog(true)

func _on_no_pressed():
	switchDeleteDialog(false)

func _on_yes_pressed():
	_on_no_pressed()
	deleteCurrentDeck()
	onEditDeckCanceled()
	
func setEditActive(active:bool):
	var setActiveBtn = $editDeck/setActive as Button
	var activeText = $editDeck/activeText as Label
	var deleteBtn = $editDeck/deleteDeck as Button
	setActiveBtn.visible = not active
	deleteBtn.visible = not active
	activeText.visible = active

func _on_set_active_pressed():
	changeActiveDeck(selectedDeck)
	setEditActive(true)
