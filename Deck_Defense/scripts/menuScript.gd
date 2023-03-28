extends Control

var settingsPanel:Panel

var windowSizes = [
	Vector2(640,360),
	Vector2(1280,720),
	Vector2(1600,900)
]

func _ready():
	settingsPanel = $Settings as Panel
	get_window().unresizable = true
	var resizeDropdown = $Settings/resizeDropdown as OptionButton
	for size in windowSizes:
		resizeDropdown.add_item(String.num(size.x) + " x " + String.num(size.y))

func _on_StartButton_pressed():
	get_tree().change_scene_to_file("res://scenes/Gameboard.tscn")

func _on_PackagesButton_pressed():
	get_tree().change_scene_to_file("res://scenes/packages.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_settings_pressed():
	settingsPanel.visible = true

func _on_close_pressed():
	settingsPanel.visible = false

func resizeWindow(index):
	if get_window().mode == Window.MODE_WINDOWED:
		get_window().size = windowSizes[index]

func fullScreen(checked):
	if checked:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
