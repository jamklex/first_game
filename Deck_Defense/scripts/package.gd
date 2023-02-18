extends Control

class_name Package


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum Style {Available, NotEnoughMoney, Sold}

var style = Style.Available
var price
var numberOfPacks = 10
var funcObj:Control
var functionName
var functionArg

var buyBtnLabel:Label
var buyBtn:Panel
var buyBtnStyle = StyleBoxFlat.new()
var availableColor = Color8(189,138,0)
var notAvailableColor = Color8(20,20,20)


# Called when the node enters the scene tree for the first time.
func _ready():
	buyBtnLabel = get_node("bar/buyButton/Label") as Label
	buyBtn = get_node("bar/buyButton") as Panel
	buyBtnStyle.bg_color = availableColor
	buyBtn.add_stylebox_override("panel", buyBtnStyle)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func setName(name):
	var label = get_node("name") as Label
	label.text = name
	
func setPrice(newPrice):
	var label = get_node("bar/price") as Label
	label.text = String(newPrice) + " Pt"
	price = newPrice
	
	
func setCover(imagePath):
	var texture = load(imagePath) as Texture
	var packHolder = get_node("packs") as Control
	for children in packHolder.get_children():
		var child = children as Sprite
		child.texture = texture

func setOnClick(target, funcName, arg):
	funcObj = target
	functionName = funcName
	functionArg = arg
	
	
func setStyle(newStyle):
	style = newStyle
	if style == Style.Available:
		buyBtnLabel.text = "Buy"
		buyBtnStyle.bg_color = availableColor
	else:
		if style == Style.NotEnoughMoney:
			buyBtnLabel.text = "Buy"
		else:
			buyBtnLabel.text = "Sold"
		buyBtnStyle.bg_color = notAvailableColor
	buyBtn.update()


func _on_buyButton_gui_input(event):
	if style == Style.Available and event is InputEventMouseButton and event.pressed:
		funcObj.call(functionName, functionArg)
