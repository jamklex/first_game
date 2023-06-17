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
	Vector2(1600,900),
	Vector2(1920,1080)
]
var selectedWindowSize = 3
var fullscreen = true


var resizeDropdown:OptionButton
var fullScreenToggle:CheckButton
var musicVolume:HSlider
var cardInfoPrefab = preload("res://scenes/menu/prefabs/cardInfo.tscn")


var cardInfos = {
	22: "This Card can attack multiple times per round.\nAt the beginning of each Round the attacks fill up again to their max.\nYou can see how often this Card is allowed to attack on the bottom right corner",
	35: "This Card can block incomming attacks, not matter how much damage they deal.\nAt the beginning of each Round this Counter is increased by 1 up too it's maximum.\nYou can see how many attacks this Card can block in the middle bottom.",
	18: "This Cards ATK will be multiplied by 1 each turn it stayed on the field.\nThis effect has no limit.",
	1: "This Card will spread their HP across every ally to their left, reducing it to 1 HP for itself.\nIf there is no Card to their left, their HP stays the same.\nBe careful, even Cards with no HP will be used in the Calculation.\nOnce placed this Card looses their effect.",
	2: "This Card will spread their HP across every ally to their right, reducing it to 1 HP for itself.\nIf there is no Card to their right, their HP stays the same.\nBe careful, even Cards with no HP will be used in the Calculation.\nOnce placed this Card looses their effect.",
	10: "This Cards HP will increase by the amount of their left ally.\nOnly direct left hand allies will count.\nOnce placed this Card looses their effect.",
	11: "This Cards HP will increase by the amount of their right ally.\nOnly direct right hand allies will count.\nOnce placed this Card looses their effect.",
	27: "This Cards ATK will increase by the amount of their left ally.\nOnly direct left hand allies will count.\nOnce placed this Card looses their effect.",
	28: "This Cards HP will increase by the amount of their right ally.\nOnly direct right hand allies will count.\nOnce placed this Card looses their effect.",
	9: "This Card destroys every Card within a Radius of 1, including allies.",
	26: "This Card mirrors the enemy Card right in front of it.\nThis will strip every effect off of the enemy Card.\nIf either this or the enemy Card is destroyed, the other will immediatly be destroyed aswell.\nIf no enemy Card exists in front of it, this Card destroys itself."
}

func _ready():
	settingsPanel = $Settings as Panel
	get_window().unresizable = true
	resizeDropdown = $Settings/resizeDropdown as OptionButton
	fullScreenToggle = $Settings/fullScreen as CheckButton
	musicVolume = $Settings/musicVolume as HSlider
	for size in windowSizes:
		resizeDropdown.add_item(String.num(size.x) + " x " + String.num(size.y))
	loadSettings()
	loadCardInfos()
	MusicPlayer.switchMusic("menu-loop.mp3")
	
func loadCardInfos():
	var cardInfosHolder = $CardInfos/ScrollContainer/CenterContainer/cardInfos as VBoxContainer
	for cardId in cardInfos.keys():
		var cardDesc = cardInfos[cardId]
		var cardInfo = cardInfoPrefab.instantiate()
		cardInfosHolder.add_child(cardInfo)
		cardInfo.setCardInfo(cardId, cardDesc)

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
	if fullscreenData != null:
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
	get_tree().change_scene_to_file("res://scenes/gameboard/_main.tscn")
	MusicPlayer.stopMusic()

func _on_med_starter_pressed():
	GbProps.enemy_level = 2
	get_tree().change_scene_to_file("res://scenes/gameboard/_main.tscn")
	MusicPlayer.stopMusic()
	
func _on_hard_starter_pressed():
	GbProps.enemy_level = 3
	get_tree().change_scene_to_file("res://scenes/gameboard/_main.tscn")
	MusicPlayer.stopMusic()

func _on_cardInfo_close_pressed():
	var cardInfos = $CardInfos as Panel
	cardInfos.visible = false

func _on_CardInfosButton_pressed():
	var cardInfos = $CardInfos as Panel
	cardInfos.visible = true
