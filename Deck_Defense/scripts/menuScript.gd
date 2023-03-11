extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_StartButton_pressed():
	get_tree().change_scene_to_file("res://scenes/Gameboard.tscn")
	
	
func _on_PackagesButton_pressed():
	get_tree().change_scene_to_file("res://scenes/packages.tscn")
	

func _on_QuitButton_pressed():
	get_tree().quit()
