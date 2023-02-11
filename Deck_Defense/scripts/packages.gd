extends Control


var pointsLabel:Label
var packageHolder
var packageScene:PackedScene
var points = 1000
var packages = []


func _ready():
	packageHolder = get_node("scrollWrapper/packageHolder")
	pointsLabel = get_node("points")
	packageScene = load("res://prefabs/package.tscn")
	_loadPackages()
	_refreshPoints()


func _refreshPoints():
	pointsLabel.text = String(points) + " Pt"


func _loadPackages():
	var rng = RandomNumberGenerator.new()
	for i in 10:
		var newPackage = packageScene.instance() as Package
		var name = "Moin" + String(i)
		var price = rng.randi_range(1,10)
		newPackage.setName(name)
		newPackage.setPrice(price)
		newPackage.setOnClick(self, "onBuyButton", i)
		packageHolder.add_child(newPackage)
		packages.append(newPackage)
#		print("Name: " + name + "; Price: " + String(price))
		

func onBuyButton(packageIndex):
	print("Buying pack with index..." + String(packageIndex))
	var selectedPackage = packages[packageIndex] as Package
	points -= selectedPackage.price
	_refreshPoints()


func _on_back_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene("res://scenes/Menu.tscn")
