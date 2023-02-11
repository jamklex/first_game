extends Control

class_name Package


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var price
var funcObj:Control
var functionName
var functionArg


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
	

func setOnClick(target, funcName, arg):
	funcObj = target
	functionName = funcName
	functionArg = arg


func _on_buyButton_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		funcObj.call(functionName, functionArg)
