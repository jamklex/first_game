extends Control


var pointsLabel:Label
var packageHolder: GridContainer
var packageScene:PackedScene = preload("res://scenes/packages/prefabs/package.tscn")
var packageCardScene:PackedScene = preload("res://scenes/packages/prefabs/packageCard.tscn")
var points = 100
var packages = []
var minPackageWidth = -1
var minPackageHeight = -1

var resultWindow:Panel
var resultCardHolder:GridContainer

var rng = RandomNumberGenerator.new()

#Open package animation stuff
var animationPackage:TextureRect


func _ready():
	rng.randomize()
	var basePanel = $bg as Panel
	packageHolder = basePanel.get_node("scrollWrapper/packageHolder")
	pointsLabel = basePanel.get_node("points")
	resultWindow = get_node("resultWindow")
	resultCardHolder = resultWindow.get_node("cardWindow/scrollWrapper/CenterContainer/cardHolder")
	animationPackage = resultWindow.get_node("package")
	_loadPackages()
	_refreshPoints()
	_afterResize()


func _refreshPoints():
	pointsLabel.text = String.num_int64(points) + " Pt"


func _refreshPackages():
	for pack in packages:
		pack = pack as Package
		if pack.numberOfPacks == 0:
			pack.setStyle(Package.Style.Sold)
		elif points < pack.price:
			pack.setStyle(Package.Style.NotEnoughMoney)
		else:
			pack.setStyle(Package.Style.Available)


func _loadPackages():
	for i in 10:
		var newPackage = packageScene.instantiate() as Package
		var name = "Moin" + String.num_int64(i)
		var price = rng.randi_range(1,10)
		var coverIndex = String.num_int64(rng.randi_range(1,4))
		var imagePath = "res://data/packs/covers/cover" + coverIndex + ".png"
		newPackage.setCover(imagePath)
		newPackage.setName(name)
		newPackage.setPrice(price)
		newPackage.setOnClick(self, "onBuyButton", i)
		packageHolder.add_child(newPackage)
		packages.append(newPackage)
		if minPackageHeight == -1:
			var rect = newPackage.custom_minimum_size
			minPackageWidth = rect[0]
			minPackageHeight = rect[1]


func onBuyButton(packageIndex):
	var selectedPackage = packages[packageIndex] as Package
	points -= selectedPackage.price
	selectedPackage.numberOfPacks -= 1
	_refreshPoints()
	_refreshPackages()
	var scrollWrapper = resultCardHolder.get_parent().get_parent() as ScrollContainer
	scrollWrapper.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	for i in rng.randi_range(1,10):
		var packageCard = packageCardScene.instantiate() as PackageCard
		resultCardHolder.add_child(packageCard)
		packageCard.setVisibility(false)
	setCardHolderColumns()	
	playOpeningAnimation(selectedPackage)
	


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/_main.tscn")


func _on_close_pressed():
	for child in resultCardHolder.get_children():
		resultCardHolder.remove_child(child)
	resultWindow.visible = false


func _on_scrollWrapper_resized():
	_afterResize()


func _afterResize():
#	setPackageHolderSeparation()
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
	# debug outputs
#	print("width cardholder: " + String.num_int64(resultCardHolder.get_rect().size.x))
#	print("width parent of cardholder: " + String.num_int64(resultCardHolder.get_parent_control().get_rect().size.x))


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
	# PACK FLY FROM LEFT TO RIGHT
	openingTween.chain().tween_property(animationPackage, "position", Vector2(packHorMid, packVertMid), 1)
	# WINDOW OPENS
	cardWindow.size = Vector2(0,5)
	cardWindow.position = Vector2(resultWindow.size.x / 2, resultWindow.size.y / 2 - cardWindow.size.y / 2)
	var widthMarginPixels = resultWindow.size.x * 0.1
	var heightMarginPixels = resultWindow.size.y * 0.1	
	# HORIZONTAL OPENING
	openingTween.chain().tween_property(cardWindow, "position", Vector2(widthMarginPixels, resultWindow.size.y / 2 - cardWindow.size.y / 2), 1)
	openingTween.tween_property(cardWindow, "size", Vector2(resultWindow.size.x-(widthMarginPixels*2), 5), 1)
	# VERTICAL OPENING
	openingTween.chain().tween_property(cardWindow, "position", Vector2(widthMarginPixels, heightMarginPixels), 1)
	openingTween.tween_property(cardWindow, "size", Vector2(resultWindow.size.x-(widthMarginPixels*2), resultWindow.size.y-(heightMarginPixels*2)), 1)
	# AFTER DOINGS
	openingTween.chain().tween_callback(onOpeningAnimationFinished)


var revealCardIndex = 0
func onOpeningAnimationFinished():
	print("finished animation")
	var cardWindow = $resultWindow/cardWindow as Panel
	cardWindow.clip_contents = false
	revealCardIndex = 0
	reveal()
	
	
func reveal():
	var cards = resultCardHolder.get_children()
	if revealCardIndex >= cards.size():
		onAllCardsRevealed()
	else:
		var packageCard = cards[revealCardIndex] as PackageCard
		packageCard.setVisibility(true)
		packageCard.setOnAnimationFinished(self, "reveal")
		packageCard.scaleCardToZero()
		packageCard.playAnimation()
		revealCardIndex += 1
	
	
func onAllCardsRevealed():
	var scrollWrapper = resultCardHolder.get_parent().get_parent() as ScrollContainer
	var closeBtn = $resultWindow/cardWindow/close as Button
	scrollWrapper.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	closeBtn.visible = true
