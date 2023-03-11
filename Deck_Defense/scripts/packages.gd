extends Control


var pointsLabel:Label
var packageHolder: GridContainer
var packageScene:PackedScene
var cardScene:PackedScene
var points = 100
var packages = []
var minPackageWidth = -1
var minPackageHeight = -1

var resultWindow:Panel
var resultWindowCards:GridContainer

var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	var basePanel = get_node("bg") as Panel
	packageHolder = basePanel.get_node("scrollWrapper/packageHolder")
	pointsLabel = basePanel.get_node("points")
	resultWindow = get_node("bg/resultWindowHolder")
	resultWindowCards = get_node("bg/resultWindowHolder/resultWindow/scrollWrapper/cardHolder")
	packageScene = load("res://prefabs/package.tscn")
	cardScene = load("res://prefabs/card.tscn")
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
		var imagePath = "res://images/packCovers/cover" + coverIndex + ".png"
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
	for child in resultWindowCards.get_children():
		resultWindowCards.remove_child(child)
	for i in rng.randi_range(1,50):
		var newCard = cardScene.instantiate()
		resultWindowCards.add_child(newCard)
	setCardHolderColumns()
	resultWindow.visible = true


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")


func _on_close_pressed():
	resultWindow.visible = false


func _on_scrollWrapper_resized():
	_afterResize()


func _afterResize():
#	setPackageHolderSeparation()
	setPackageSize()
	setCardHolderColumns()

func setCardHolderColumns():
	if not resultWindowCards:
		return
	
	var childCount = resultWindowCards.get_child_count()
	if childCount <= 0:
		return
	var firstCard = resultWindowCards.get_child(0) as Control
	var cardWidth = firstCard.custom_minimum_size[0]
	var currentWidth = resultWindowCards.get_parent_control().get_rect().size.x
	var columns = int(currentWidth / cardWidth)
	resultWindowCards.columns = columns


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
#	print(columns)	
#	var separation = packageHolder.get_constant("h_separation")
#	separation += 1
#	print(separation)
