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
	indicator = $indicator as Control
	self.custom_minimum_size[0] = card.custom_minimum_size[0]
	self.custom_minimum_size[1] = card.custom_minimum_size[1]
	_changeSelectStyle()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _switchSelect():
	selected = not selected
	_changeSelectStyle()
	##  onclick function trigger
	if funcObj != null:
		funcObj.call(funcName)

func setSelected(newSelected:bool):
	selected = newSelected
	_changeSelectStyle()
	
func getCard() -> Card:
	return card

func setOnClick(newFuncObj, newFuncName):
	funcObj = newFuncObj
	funcName = newFuncName

func _changeSelectStyle():
	indicator.visible = selected
	if selected:
		card.modulate = Color(1,1,1,1)
		card.scale = Vector2(1,1)
		card.position = Vector2(0,0)
	else:
		card.modulate = Color(1,1,1,0.6)
		card.scale = Vector2(0.8,0.8)	#(0.9,0.9)
		card.position = Vector2(16,24)	#(8,12)
