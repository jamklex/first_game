extends Control

class_name Package

enum Style {Available, NotEnoughMoney, Sold, NotUnlocked}

var style = Style.Available
var price
var locked:bool = false
var cards
var numberOfPacks = 10
var funcObj:Control
var functionName
var functionArg

var buyBtn:Button
var availableColor = Color.WHITE
var notAvailableColor = Color.BLACK
var soldLayer:Panel
var coverTexture:Texture2D

func _ready():
	buyBtn = get_node("main/bar/MarginContainer/buyButton")
	soldLayer = get_node("soldLayer")

func setName(name):
	var label = get_node("main/name") as Label
	label.text = name

func setPrice(newPrice):
	var label = get_node("main/bar/price") as Label
	label.text = String.num_int64(newPrice) + " Pt"
	price = newPrice

func setLocked(newLocked):
	locked = newLocked

func setCards(newCards):
	cards = newCards

func setCover(imagePath):
	var texture = load(imagePath) as Texture2D
	coverTexture = texture
	var packHolder = get_node("main/packs") as Control
	for child in packHolder.get_children():
		var coverHolder = child as Panel
		var cover = coverHolder.get_child(0) as TextureRect
		cover.texture = texture

func setOnClick(target, funcName):
	funcObj = target
	functionName = funcName

func setStyle(newStyle):
	style = newStyle
	if style == Style.Available:
		buyBtn.text = "Buy"
		buyBtn.disabled = false
		buyBtn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		buyBtn.add_theme_color_override("font_color", availableColor)
		soldLayer.visible = false
	else:
		if style == Style.NotEnoughMoney:
			buyBtn.text = "Buy"
			soldLayer.visible = false
		elif style == Style.NotUnlocked:
			buyBtn.text = "Locked"
			soldLayer.visible = false
		elif style == Style.Sold:
			buyBtn.text = "Buy"
			soldLayer.visible = true
		buyBtn.add_theme_color_override("font_color", notAvailableColor)
		buyBtn.disabled = true

func _on_buyButton_pressed():
	if style == Style.Available:
		funcObj.call(functionName, self)
