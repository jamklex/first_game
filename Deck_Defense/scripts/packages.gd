extends Control




func _ready():
	pass # Replace with function body.


func _on_back_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene("res://scenes/Menu.tscn")
