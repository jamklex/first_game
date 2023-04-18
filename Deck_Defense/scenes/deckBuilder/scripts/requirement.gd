extends Panel
class_name Requirement

var active:bool = false
var textLabel:Label = null
var activePanel:Sprite2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	textLabel = $text
	activePanel = $activeWrapper/active

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setText(newText:String):
	textLabel.text = newText
	
func setActive(newActive:bool):
	active = newActive
	activePanel.visible = active
	var textColor = Color(1,1,1,0.5)
	if not active:
		textColor = Color(1,1,1,1)
	textLabel.add_theme_color_override("font_color", textColor)
