extends Control

var pointsLabel:Label
var packageHolder: GridContainer
var packageScene:PackedScene = preload("res://scenes/packages/prefabs/package.tscn")
var packageCardScene:PackedScene = preload("res://scenes/packages/prefabs/packageCard.tscn")
var points = 1000
var packages = []
var minPackageWidth = -1
var minPackageHeight = -1

var resultWindow:Panel
var resultCardHolder:GridContainer

var rng = RandomNumberGenerator.new()

#Open package animation stuff
var animationPackage:TextureRect

var playerData = JsonReader.read_player_data()

func _ready():
	rng.randomize()
	var basePanel = $bg as Panel
	packageHolder = basePanel.get_node("scrollWrapper/packageHolder")
	pointsLabel = basePanel.get_node("points/text")
	resultWindow = get_node("resultWindow")
	resultCardHolder = resultWindow.get_node("cardWindow/scrollWrapper/CenterContainer/cardHolder")
	animationPackage = resultWindow.get_node("package")
	if "points" in playerData:
		points = playerData["points"]
	_loadPackages()
	_refreshPoints()
	_afterResize()
	_refreshPackages()
	get_tree().set_auto_accept_quit(false)  # block normal close request

func _refreshPoints():
	pointsLabel.text = String.num_int64(points) + " Pt"

func _refreshPackageCards(cards_to_remove, except_pack):
	for pack in packages:
		if pack == except_pack:
			continue
		for id in cards_to_remove:
			if pack.cards.has(id):
				pack.cards.erase(id)

func _refreshPackages():
	for pack in packages:
		pack = pack as Package
		if pack.locked:
			pack.setStyle(Package.Style.NotUnlocked)
		elif pack.numberOfPacks == 0 or pack.cards.is_empty():
			pack.setStyle(Package.Style.Sold)
		elif points < pack.price:
			pack.setStyle(Package.Style.NotEnoughMoney)
		else:
			pack.setStyle(Package.Style.Available)

func _loadPackages():
	var packs = JsonReader.package_paths()
	var player_card_amounts = flat_map(playerData["cards"])
	var player_unlocks = playerData["unlocks"]
	for pack in packs:
		var before = Time.get_ticks_msec()
		var pack_data = JsonReader.read_json_cached(pack)
		var card_difference = card_difference(player_card_amounts, pack_data["cards"])
		var newPackage = packageScene.instantiate() as Package
		newPackage.setCover(pack_data["image"])
		newPackage.setName(pack_data["name"])
		newPackage.setPrice(pack_data["price"])
		newPackage.setLocked(!check_unlock(pack_data["unlock_needed"], player_unlocks))
		newPackage.setCards(card_difference)
		newPackage.setOnClick(self, "onBuyButton")
		packageHolder.add_child(newPackage)
		packages.append(newPackage)
		if minPackageHeight == -1:
			var rect = newPackage.custom_minimum_size
			minPackageWidth = rect[0]
			minPackageHeight = rect[1]
		print(Time.get_ticks_msec() - before)

func flat_map(card_info_array):
	var card_dict = {} as Dictionary
	for card_info in card_info_array:
		card_dict[card_info["id"]] = card_info["amount"]
	return card_dict

func card_difference(player_cards, pack_cards):
	var remaining_cards = []
	for id in pack_cards:
		var max = CardProperties.of(id).max_owned
		if player_cards.has(id):
			max = max(0, max - player_cards[id])
		for x in max:
			remaining_cards.append(id)
	return remaining_cards

func onBuyButton(selectedPackage):
	if resultWindow.visible:
		return
	points -= selectedPackage.price
	selectedPackage.numberOfPacks -= 1
	var cards_for_player = []
	var scrollWrapper = resultCardHolder.get_parent().get_parent() as ScrollContainer
	scrollWrapper.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	for i in 5:
		var relevant_cards = selectedPackage.cards
		if relevant_cards.is_empty():
			break
		var packageCard = packageCardScene.instantiate() as PackageCard
		var random_card_id = relevant_cards.pop_at(rng.randi_range(0, relevant_cards.size()-1))
		cards_for_player.append(random_card_id)
		packageCard.get_node("front").initialize_from_id(random_card_id)
		resultCardHolder.add_child(packageCard)
		packageCard.setVisibility(false)
	_refreshPoints()
	add_player_cards(cards_for_player)
	_refreshPackageCards(cards_for_player, selectedPackage)
	_refreshPackages()
	playOpeningAnimation(selectedPackage)

func _on_back_pressed():
	_savePlayerData()
	get_tree().change_scene_to_file("res://scenes/menu/_main.tscn")

func _savePlayerData():
	playerData["points"] = points
	JsonReader.save_player_data(playerData)

func _on_close_pressed():
	print("pressed")
	for child in resultCardHolder.get_children():
		resultCardHolder.remove_child(child)
	resultWindow.visible = false

func _on_scrollWrapper_resized():
	_afterResize()

func _afterResize():
	setPackageSize()
	setCardHolderColumns()

func setCardHolderColumns():
	if not resultCardHolder:
		return	
	var childCount = resultCardHolder.get_child_count()
	if childCount <= 0:
		return
	var firstCard = resultCardHolder.get_child(0) as Control
	var cardWidth = firstCard.custom_minimum_size[0]
	var currentWidth = resultCardHolder.get_parent_control().get_parent_control().get_rect().size.x
	currentWidth -= 20
	var columns = int(currentWidth / cardWidth)
	resultCardHolder.columns = columns

func setPackageSize():
	if minPackageHeight == -1:
		return
	var width = packageHolder.get_parent().size[0] - 12
	var columns = packageHolder.columns
	var separation = packageHolder.get_theme_constant("h_separation")
	var usedWidth = (columns-1) * separation
	var freeWidth = width - usedWidth
	var newPackageWidth = freeWidth / columns
	if newPackageWidth < minPackageWidth:
		return
	var widthSizeVal = newPackageWidth / minPackageWidth
	var newPackageHeight = minPackageHeight * widthSizeVal
	for package in packages:
		package = package as Package
		package.custom_minimum_size[0] = newPackageWidth
		package.custom_minimum_size[1] = newPackageHeight

func setPackageHolderSeparation():
	if minPackageHeight == -1:
		return
	var width = packageHolder.get_parent().size[0] - 12
	var columns = packageHolder.columns
	var usedWidth = columns * minPackageWidth
	var freeWidth = width - usedWidth
	var neededSeparation = freeWidth / (columns-1)
	packageHolder.add_theme_constant_override("h_separation", neededSeparation)

###### ANIMATION STUFF
func playOpeningAnimation(selectedPackage: Package):
	var animationPackage = $resultWindow/package as TextureRect
	var cardWindow = $resultWindow/cardWindow as Panel
	cardWindow.clip_contents = true
	var cardWindowCloseBtn = $resultWindow/cardWindow/close as Button
	animationPackage.texture = selectedPackage.coverTexture
	resultWindow.visible = true
	cardWindowCloseBtn.visible = false
	var packHorMid = resultWindow.size.x / 2 - animationPackage.size.x / 2
	var packVertMid = resultWindow.size.y / 2 - animationPackage.size.y / 2
	cardWindow.size = Vector2(0,0)
	animationPackage.position = Vector2(resultWindow.size.x, packVertMid)
	var openingTween = create_tween().set_parallel(true)
	# PACK FLY FROM RIGHT TO LEFT
	openingTween.chain().tween_property(animationPackage, "position", Vector2(packHorMid, packVertMid), 0.2)
	# WINDOW OPENS
	cardWindow.size = Vector2(0,5)
	cardWindow.position = Vector2(resultWindow.size.x / 2, resultWindow.size.y / 2 - cardWindow.size.y / 2)
	var widthMarginPixels = resultWindow.size.x * 0.1
	var heightMarginPixels = resultWindow.size.y * 0.1	
	# HORIZONTAL OPENING
	openingTween.chain().tween_property(cardWindow, "position", Vector2(widthMarginPixels, resultWindow.size.y / 2 - cardWindow.size.y / 2), 0.2)
	openingTween.tween_property(cardWindow, "size", Vector2(resultWindow.size.x-(widthMarginPixels*2), 5), 0.2)
	# VERTICAL OPENING
	openingTween.chain().tween_property(cardWindow, "position", Vector2(widthMarginPixels, heightMarginPixels), 0.2)
	openingTween.tween_property(cardWindow, "size", Vector2(resultWindow.size.x-(widthMarginPixels*2), resultWindow.size.y-(heightMarginPixels*2)), 0.2)
	# AFTER DOINGS
	openingTween.chain().tween_callback(onResultWindowOpen)

var currentAnimationCardIndex = 0
func onResultWindowOpen():
	setCardHolderColumns()
	var cardWindow = $resultWindow/cardWindow as Panel
	cardWindow.clip_contents = false
	currentAnimationCardIndex = 0
	showCard()

func showCard():
	var cards = resultCardHolder.get_children()
	if currentAnimationCardIndex >= cards.size():
		currentAnimationCardIndex = 0
		revealCard()
	else:
		var packageCard = cards[currentAnimationCardIndex] as PackageCard
		packageCard.setVisibility(true)
		packageCard.setOnShowDoneFinished(self, "showCard")
		packageCard.scaleCardToZero()
		packageCard.playShowAnimation()
		currentAnimationCardIndex += 1

func revealCard():
	var cards = resultCardHolder.get_children()
	if currentAnimationCardIndex >= cards.size():
		onAllCardsRevealed()
	else:
		var packageCard = cards[currentAnimationCardIndex] as PackageCard
		packageCard.setOnRevealDoneFinished(self, "revealCard")
		packageCard.playRevealAnimation()
		currentAnimationCardIndex += 1

func onAllCardsRevealed():
	var scrollWrapper = resultCardHolder.get_parent().get_parent() as ScrollContainer
	var closeBtn = $resultWindow/cardWindow/close as Button
	scrollWrapper.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	closeBtn.visible = true

func add_player_cards(cards_for_player):
	for cardId in cards_for_player:
		var playerCardData = null
		for cardData in playerData["cards"]:
			if cardData["id"] == cardId:
				playerCardData = cardData
				break
		if playerCardData == null:
			playerCardData = {}
			playerCardData["id"] = cardId
			playerCardData["amount"] = 1
			playerData["cards"].append(playerCardData)
		else:
			playerCardData["amount"] += 1

# handle close request
func _notification(what):   
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_savePlayerData()
		get_tree().quit()

func check_unlock(unlocks_required, unlocks_performed):
	for unlock in unlocks_required:
		if not unlocks_performed.has(unlock):
			return false
	return true
