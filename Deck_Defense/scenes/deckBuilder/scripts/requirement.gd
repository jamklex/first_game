extends Panel
class_name Requirement

var active:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setText(newText:String):
	var textLabel = $text as Label
	textLabel.text = newText
	
func setActive(newActive:bool):
	var activePanel = $activeWrapper/active
	active = newActive
	activePanel.visible = active
	
