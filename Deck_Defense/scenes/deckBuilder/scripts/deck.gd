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
	
func setOnActiveCheckClicked(newFuncObj, funcName):
	activeFuncObj = newFuncObj
	activeFunctionName = funcName

func setOnEditButtonClicked(newFuncObj, funcName):
	editFuncObj = newFuncObj
	editFunctionName = funcName
	
func setOnDeleteButtonClicked(newFuncObj, funcName):
	deleteFuncObj = newFuncObj
	deleteFunctionName = funcName
	
func setDeckName(newName):
	var labelName = $name as Label
	labelName.text = newName
	
func getDeckName():
	var labelName = $name as Label
	return labelName.text	
	
func setActive(newActive):
	var activeBox = $active as CheckBox
	activeBox.button_pressed = newActive
	var deleteBtn = $deleteBtn as Button
	deleteBtn.disabled = newActive
	active = newActive
	
func closeEditName():
	_showNameEdit(false)
	
func _showNameEdit(show:bool):
	var name = $name as Label
	var nameEdit = $nameEdit as LineEdit
	name.visible = not show
	nameEdit.visible = show
	nameEdit.text = getDeckName()
	if show:
		nameEdit.grab_focus()

func _on_edit_btn_pressed():
	if editFuncObj:
		editFuncObj.call(editFunctionName, self)
	onEveryAction.emit()

func _on_active_pressed():
	if activeFuncObj:
		activeFuncObj.call(activeFunctionName, self)
	onEveryAction.emit()

func _on_delete_btn_pressed():
	if deleteFuncObj:
		deleteFuncObj.call(deleteFunctionName, self)
	onEveryAction.emit()

func _on_name_gui_input(event):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.double_click:
			onEveryAction.emit()
			_showNameEdit(true)

func _on_name_edit_text_submitted(newName:String):
	if newName.length() > 0:
		setDeckName(newName)
		_showNameEdit(false)
