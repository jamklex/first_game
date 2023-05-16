extends Node

class_name EndWindow


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/_main.tscn")


func _on_retry_button_pressed():
	get_tree().change_scene_to_file("res://scenes/gameboard/_main.tscn")

func setPoints(points):
	var pointsLabel = $points as Label
	pointsLabel.text = "+ " + str(points) + " Points"
