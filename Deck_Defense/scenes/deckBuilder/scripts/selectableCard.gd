extends Control
class_name SelectableCard

var card:Control
var selected: bool
var indicator:Control

# Called when the node enters the scene tree for the first time.
func _ready():
	selected = false
	card = $Card as Control
	indicator = $indicator
	self.custom_minimum_size[0] = card.custom_minimum_size[0]
	self.custom_minimum_size[1] = card.custom_minimum_size[1]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _switchSelect():
	selected = not selected
	indicator.visible = selected
