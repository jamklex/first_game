extends Panel

class_name Deck

### on click edit button
var editFuncObj:Control
var editFunctionName
var editFunctionArg
####
### on click active check
var activeFuncObj:Control
var activeFunctionName
var activeFunctionArg
####


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func setOnActiveCheckClicked(newFuncObj, funcName, funcArg):
	activeFuncObj = newFuncObj
	activeFunctionName = funcName
	activeFunctionArg = funcArg

func setOnEditButtonClicked(newFuncObj, funcName, funcArg):
	editFuncObj = newFuncObj
	editFunctionName = funcName
	editFunctionArg = funcArg
	
func setDeckName(newName):
	var labelName = $name as Label
	labelName.text = newName
	
func setActive(newActive):
	var activeBox = $active as CheckBox
	activeBox.button_pressed = newActive	

func _on_edit_btn_pressed():
	if editFuncObj:
		editFuncObj.call(editFunctionName, editFunctionArg)

func _on_active_pressed():
	if activeFuncObj:
		activeFuncObj.call(activeFunctionName, activeFunctionArg)
