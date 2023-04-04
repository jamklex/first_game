extends Control

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
	deckHolder = $bg/deckWrapper/center/deckHolder
	cardHolder = $editDeck/vertAlign/cardWrapper/center/cardHolder
	rng.randomize()
	addRandomDecks()
	
	
func addRandomDecks():
	## CLEAR ALREADY EXISTING DECKS
	for child in deckHolder.get_children():
		deckHolder.remove_child(child)
	decks.clear()
	##### ADD NEW DECKS
	var numOfDecks = rng.randi_range(10, 20)
	for i in numOfDecks:
		var newDeck = deckScene.instantiate() as Deck
		newDeck.setDeckName("Deck " + String.num_int64(i))
		newDeck.setOnEditButtonClicked(self, "onDeckEditBtnClicked", i)
		newDeck.setOnActiveCheckClicked(self, "onDeckActiveCheckClicked", i)
		deckHolder.add_child(newDeck)
		decks.append(newDeck)
	setDeckHolderColumns()
		
func onDeckEditBtnClicked(index):
	print("opening pack with index: " + String.num_int64(index))
	addRandomCards()
	setCardHolderColumns()
	editDeck.visible = true
	
func onDeckActiveCheckClicked(activeIndex):
	for index in decks.size():
		var deck = decks[index] as Deck
		deck.setActive(index==activeIndex)
	
func addRandomCards():
	var numOfCards = rng.randi_range(10, 30)
	for i in numOfCards:
		var newCard = cardScene.instantiate()
		cardHolder.add_child(newCard)
		cards.append(newCard)

func _on_deck_wrapper_resized():
	pass

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/_main.tscn")

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
