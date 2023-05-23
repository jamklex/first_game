extends Control

var settingsPanel:Panel

## actual settings
var settings = preload("res://shared/settings.gd").new()
var KEY_FULLSCREEN = "fullscreen"
var KEY_WINDOWSIZE_WIDTH = "windowSizeWidth"
var KEY_WINDOWSIZE_HEIGHT = "windowSizeHeight"
var KEY_MUSICPLAYER_VOLUME = "musicPlayerVol"
###


var windowSizes = [
	Vector2(1280,720),
	Vector2(1366,768),
	Vector2(1600,900)
]
var selectedWindowSize = 0
var fullscreen = false


var resizeDropdown:OptionButton
var fullScreenToggle:CheckButton
var musicVolume:HSlider

func _ready():
	settingsPanel = $Settings as Panel
	get_window().unresizable = true
	resizeDropdown = $Settings/resizeDropdown as OptionButton
	fullScreenToggle = $Settings/fullScreen as CheckButton
	musicVolume = $Settings/musicVolume as HSlider
	for size in windowSizes:
		resizeDropdown.add_item(String.num(size.x) + " x " + String.num(size.y))
	loadSettings()
	MusicPlayer.switchMusic("menu-loop.mp3")

func _on_StartButton_pressed():
	var starters = $Starters as Panel
	starters.visible = true	

func _on_deck_button_pressed():
	get_tree().change_scene_to_file("res://scenes/deckBuilder/_main.tscn")

func _on_PackagesButton_pressed():
	get_tree().change_scene_to_file("res://scenes/packages/_main.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_settings_pressed():
	settingsPanel.visible = true

func _on_close_pressed():
	settingsPanel.visible = false

func resizeWindow(index):
	resizeDropdown.selected = index
	if get_window().mode == Window.MODE_WINDOWED:
		get_window().size = windowSizes[index]
	selectedWindowSize = index
	onSettingsChanged()

func changeFullscreen(checked):
	fullScreenToggle.button_pressed = checked
	if checked:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
	fullscreen = checked
	onSettingsChanged()
	
func setVolume(volume):
	musicVolume.value = volume
	MusicPlayer.setVolume(volume)
	onSettingsChanged()

func onVolumeSliderDragged(volumeChanged):
	if volumeChanged:
		setVolume(musicVolume.value)
		
func onSettingsChanged():
	settings.setData(KEY_FULLSCREEN, fullscreen)
	var windowSize = windowSizes[selectedWindowSize]
	settings.setData(KEY_WINDOWSIZE_WIDTH, windowSize.x)
	settings.setData(KEY_WINDOWSIZE_HEIGHT, windowSize.y)
	settings.setData(KEY_WINDOWSIZE_HEIGHT, windowSize.y)
	settings.setData(KEY_MUSICPLAYER_VOLUME, MusicPlayer.volume)
	settings.saveData()

func loadSettings():
	var width = settings.getData(KEY_WINDOWSIZE_WIDTH)
	var height = settings.getData(KEY_WINDOWSIZE_HEIGHT)
	var fullscreenData = settings.getData(KEY_FULLSCREEN)
	var musicVolume = settings.getData(KEY_MUSICPLAYER_VOLUME)
	# LOAD IF EXISTS
	if width and height:
		selectedWindowSize = getIndexByWidthAndHeigth(width, height)
	if fullscreenData:
		fullscreen = fullscreenData
	if musicVolume != null:
		MusicPlayer.setVolume(musicVolume)
	else: 
		musicVolume = MusicPlayer.volume
	# APPLY SETTINGS
	resizeWindow(selectedWindowSize)
	changeFullscreen(fullscreen)
	setVolume(musicVolume)
	
func getIndexByWidthAndHeigth(width, height):
	for index in windowSizes.size():
		var windowSize = windowSizes[index]
		if windowSize.x == width and windowSize.y == height:
			return index
	return 0

func _on_close_starter_pressed():
	var starters = $Starters as Panel
	starters.visible = false

func _on_easy_starter_pressed():
	GbProps.enemy_level = 1
	MusicPlayer.switchMusic("boss_1-loop.mp3")
	get_tree().change_scene_to_file("res://scenes/gameboard/_main.tscn")

func _on_med_starter_pressed():
	GbProps.enemy_level = 2
	MusicPlayer.switchMusic("boss_2-loop.mp3")
	get_tree().change_scene_to_file("res://scenes/gameboard/_main.tscn")
	
func _on_hard_starter_pressed():
	GbProps.enemy_level = 3
	MusicPlayer.switchMusic("boss_3-loop.mp3")
	get_tree().change_scene_to_file("res://scenes/gameboard/_main.tscn")
