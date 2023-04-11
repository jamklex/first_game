extends Control

var playerDataJsonPath = "res://data/player.json"
var jsonReader = preload("res://shared/scripts/json_reader.gd").new()
var deckScene:PackedScene = preload("res://scenes/deckBuilder/prefabs/deck.tscn")
var cardScene:PackedScene = preload("res://scenes/deckBuilder/prefabs/selectableCard.tscn")
var rng = RandomNumberGenerator.new()
var decks = []
var cards = []
var editDeck:Control   
var deckHolder:GridContainer
var cardHolder:GridContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	editDeck = $editDeck
	deckHolder = $bg/deckBg/margin/deckWrapper/center/deckHolder
	cardHolder = $editDeck/vertAlign/cardWrapper/center/cardHolder
	rng.randomize()
	_loadDecks()
#	get_tree().set_auto_accept_quit(false)  # for reacting on close request
	
func _loadDecks():
	var decksData = jsonReader.read_json(playerDataJsonPath)
	for deckData in decksData["decks"]:
		var newDeck = deckScene.instantiate() as Deck
		newDeck.setDeckName(deckData["name"])
		newDeck.setOnEditButtonClicked(self, "onDeckEditBtnClicked")
		newDeck.setOnActiveCheckClicked(self, "onDeckActiveCheckClicked")
		newDeck.setOnDeleteButtonClicked(self, "onDeckDeleteBtnClicked")
		newDeck.setActive(deckData["active"])
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
	setCardHolderColumns()
	editDeck.visible = true
	
func onDeckActiveCheckClicked(activeDeck:Deck):
	for index in decks.size():
		var deck = decks[index] as Deck
		deck.setActive(deck == activeDeck)

func loadCards():
	var playerData = jsonReader.read_json(playerDataJsonPath)
	for cardData in playerData["cards"]:
		for i in range(cardData["amount"]):
			var newCard = cardScene.instantiate()
			newCard.get_node("Card").initialize_from_id(cardData["id"])
			cardHolder.add_child(newCard)
			cards.append(newCard)

func _on_deck_wrapper_resized():
	pass

func _on_back_pressed():
	_beforeLeave()
	get_tree().change_scene_to_file("res://scenes/menu/_main.tscn")
	
func _beforeLeave():
	print("_beforeLeave")

#func _notification(what):    # actually u can handle then the close request here
#	if what == NOTIFICATION_WM_CLOSE_REQUEST:
#		_beforeLeave()
#		get_tree().quit()

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
	cleanCardHolder()

func cleanCardHolder():
	for child in cardHolder.get_children():
		cardHolder.remove_child(child)
	cards.clear()

func onEditDeckDone():
	pass # Replace with function body.

func _on_new_deck_pressed():
	var newDeck = deckScene.instantiate() as Deck
	newDeck.setDeckName("New Deck")
	newDeck.setOnEditButtonClicked(self, "onDeckEditBtnClicked")
	newDeck.setOnActiveCheckClicked(self, "onDeckActiveCheckClicked")
	newDeck.setOnDeleteButtonClicked(self, "onDeckDeleteBtnClicked")
	deckHolder.add_child(newDeck)
	decks.append(newDeck)
