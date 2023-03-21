extends Control

class_name PackageCard

var card:Control
# Called when the node enters the scene tree for the first time.
func _ready():
	card = get_node("Card") as Control
	custom_minimum_size = card.custom_minimum_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setVisibility(newVisibility:bool):
	card.visible = newVisibility
