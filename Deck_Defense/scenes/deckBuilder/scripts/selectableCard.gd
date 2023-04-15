extends Control
class_name SelectableCard

var card: Card
var selected: bool
var indicator:Control

var funcObj:Control
var funcName:String

# Called when the node enters the scene tree for the first time.
func _ready():
	selected = false
	card = $Card as Card
	indicator = $indicator
	self.custom_minimum_size[0] = card.custom_minimum_size[0]
	self.custom_minimum_size[1] = card.custom_minimum_size[1]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _switchSelect():
	selected = not selected
	indicator.visible = selected
	if funcObj != null:
		funcObj.call(funcName)

func setSelected(newSelected:bool):
	selected = newSelected
	indicator.visible = newSelected
	
func getCard() -> Card:
	return card

func setOnClick(newFuncObj, newFuncName):
	funcObj = newFuncObj
	funcName = newFuncName
