extends Panel

class_name Deck

### on click edit button
var editFuncObj:Control   
var editFunctionName
####
### on click active check
var activeFuncObj:Control
var activeFunctionName
####
### on click delete button
var deleteFuncObj:Control
var deleteFunctionName
### onEveryAction
signal onEveryAction
####
var active = false
var cards = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func setOnEditButtonClicked(newFuncObj, funcName):
	editFuncObj = newFuncObj
	editFunctionName = funcName
	
func setDeckName(newName):
	var labelName = $name as Label
	labelName.text = newName
	
func getDeckName():
	var labelName = $name as Label
	return labelName.text
	
func setActive(newActive):
	var activeText = $activeText as Label
	activeText.visible = newActive
	active = newActive

func _on_pressed():
	if editFuncObj:
		editFuncObj.call(editFunctionName, self)

func _on_gui_input(event):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.pressed and not event.double_click:
			_on_pressed()
