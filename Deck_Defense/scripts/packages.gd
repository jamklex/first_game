extends Control


var pointsLabel:Label
var packageHolder
var packageScene:PackedScene
var cardScene:PackedScene
var points = 100
var packages = []

var resultWindow:Panel
var resultWindowCards:GridContainer

var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	var basePanel = get_node("CenterContainer/Panel") as Panel
	packageHolder = basePanel.get_node("scrollWrapper/packageHolder")
	pointsLabel = basePanel.get_node("points")
	resultWindow = basePanel.get_node("resultWindow")
	resultWindowCards = basePanel.get_node("resultWindow/scrollWrapper/cardHolder")
	packageScene = load("res://prefabs/package.tscn")
	cardScene = load("res://prefabs/card.tscn")
	_loadPackages()
	_refreshPoints()


func _refreshPoints():
	pointsLabel.text = String(points) + " Pt"
	
	
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
		var newPackage = packageScene.instance() as Package
		var name = "Moin" + String(i)
		var price = rng.randi_range(1,10)
		var coverIndex = String(rng.randi_range(1,3))
		var imagePath = "res://images/packCovers/cover" + coverIndex + ".png"
		newPackage.setCover(imagePath)
		newPackage.setName(name)
		newPackage.setPrice(price)
		newPackage.setOnClick(self, "onBuyButton", i)
		packageHolder.add_child(newPackage)
		packages.append(newPackage)
		

func onBuyButton(packageIndex):
	var selectedPackage = packages[packageIndex] as Package
	points -= selectedPackage.price
	selectedPackage.numberOfPacks -= 1
	_refreshPoints()
	_refreshPackages()
	for child in resultWindowCards.get_children():
		resultWindowCards.remove_child(child)
	for i in rng.randi_range(1,10):
		var newCard = cardScene.instance()
		resultWindowCards.add_child(newCard)
	resultWindow.visible = true


func _on_back_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene("res://scenes/Menu.tscn")


func _on_close_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		resultWindow.visible = false
