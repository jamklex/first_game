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
var buyBtn:Button
#var buyBtnStyle = StyleBoxFlat.new()
var availableColor = Color.white
var notAvailableColor = Color.black
var soldLayer:Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	buyBtnLabel = get_node("bar/buyButton/Label") as Label
	buyBtn = get_node("bar/buyButton")
	soldLayer = get_node("soldLayer")
#	buyBtnStyle.bg_color = availableColor
#	buyBtn.add_stylebox_override("normal", buyBtnStyle)


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
		var coverHolder = children as Panel
		var cover = coverHolder.get_child(0) as TextureRect
		cover.texture = texture

func setOnClick(target, funcName, arg):
	funcObj = target
	functionName = funcName
	functionArg = arg
	
	
func setStyle(newStyle):
	style = newStyle
	if style == Style.Available:
		buyBtnLabel.text = "Buy"
		buyBtn.disabled = false
		buyBtnLabel.add_color_override("font_color", availableColor)
		soldLayer.visible = false
#		buyBtnStyle.bg_color = availableColor
	else:
		if style == Style.NotEnoughMoney:
			buyBtnLabel.text = "Buy"
			soldLayer.visible = false
		else:
			buyBtnLabel.text = "Sold"
			soldLayer.visible = true
		buyBtnLabel.add_color_override("font_color", notAvailableColor)
		buyBtn.disabled = true
#		buyBtnStyle.bg_color = notAvailableColor
#	buyBtn.update()
	

func _on_buyButton_pressed():
	if style == Style.Available:
		funcObj.call(functionName, functionArg)
