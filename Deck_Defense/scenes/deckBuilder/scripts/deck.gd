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
####
var active = false


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
	
func setActive(newActive):
	var activeBox = $active as CheckBox
	activeBox.button_pressed = newActive
	var deleteBtn = $deleteBtn as Button
	deleteBtn.disabled = newActive
	active = newActive
	
func _showNameEdit(show:bool):
	var name = $name as Label
	var nameEdit = $nameEdit as LineEdit
	name.visible = not show
	nameEdit.visible = show
	if show:
		nameEdit.grab_focus()

func _on_edit_btn_pressed():
	if editFuncObj:
		editFuncObj.call(editFunctionName, self)

func _on_active_pressed():
	if activeFuncObj:
		activeFuncObj.call(activeFunctionName, self)

func _on_delete_btn_pressed():
	if deleteFuncObj:
		deleteFuncObj.call(deleteFunctionName, self)

func _on_name_gui_input(event):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.double_click:
			print("double clicked name...")
			_showNameEdit(true)

func _on_name_edit_text_submitted(newName:String):
	if newName.length() > 0:
		setDeckName(newName)
		_showNameEdit(false)
