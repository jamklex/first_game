extends Control


var packageHolder
var packageScene:PackedScene



func _ready():
	packageHolder = get_node("scrollWrapper/packageHolder")
	packageScene = load("res://prefabs/package.tscn")
	_loadPackages()


func _loadPackages():
	for i in 10:
		var newPackage = packageScene.instance()
		var label = newPackage.get_node("name") as Label
		label.text = "Moooin " + String(i)
		var buyButton = newPackage.get_node("bar/buyButton") as Control
		buyButton.connect("gui_input",self,"onBuyButton", [i])
		packageHolder.add_child(newPackage)
		

func onBuyButton(event, packageIndex):
	if event is InputEventMouseButton and event.pressed:
		print("buying..." + String(packageIndex))


func _on_back_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene("res://scenes/Menu.tscn")
