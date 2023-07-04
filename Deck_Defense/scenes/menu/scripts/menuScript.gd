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
	22: GbUtil.cardInfos[MultiAttackEffect.PANEL],
	35: GbUtil.cardInfos[StoneEffect.PANEL],
	18: GbUtil.cardInfos[KanonenrohrEffect.PANEL],
	1: GbUtil.cardInfos[AngelEffect.PANEL + "_l"],
	2: GbUtil.cardInfos[AngelEffect.PANEL + "_r"],
	10: GbUtil.cardInfos[FlexerEffect.PANEL + "_l"],
	11: GbUtil.cardInfos[FlexerEffect.PANEL + "_r"],
	27: GbUtil.cardInfos[SoldierEffect.PANEL + "_l"],
	28: GbUtil.cardInfos[SoldierEffect.PANEL + "_r"],
	9: GbUtil.cardInfos[BombEffect.PANEL],
	26: GbUtil.cardInfos[ParasiteEffect.PANEL]
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
	if settings.getData(KEY_TUT_DONE):
		enableStartButton()
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
	
func enableStartButton():
	var startButton = $VBoxContainer/StartButton as LinkButton
	startButton.disabled = false
	var tutorialButton = $VBoxContainer/Tutorial as LinkButton
	tutorialButton.remove_theme_color_override("font_color")
	tutorialButton.text = "Tutorial"

#### TUTORIAL
var tutorialPages = [
	{
		"title": "Placing cards",
		"videoPath": "res://data/videos/tutorial/1_placingCards.ogv",
		"desc": "You can place cards by selecting them from Your hand card via the left mouse button.\nAfterwards You can select a free spot on Your side of the field to place them."
	},
	{
		"title": "Placing cards",
		"videoPath": "res://data/videos/tutorial/2_switchByBlockOpponent.ogv",
		"desc": "After placing Your cards, end Your turn by clicking on the shield icon, so Your opponent can react."
	},
	{
		"title": "Attacking",
		"videoPath": "res://data/videos/tutorial/3_switchByAttackOpponent.ogv",
		"desc": "You can attack Your opponent after his turn ends by clicking on the swords icon.\nAfter attacking Your turn will end automatically."
	},
	{
		"title": "Card infos overview",
		"videoPath": "res://data/videos/tutorial/4_cardInfos.ogv",
		"desc": "You can find information about the different types of cards in the main menu under the section 'Card infos'."
	}, 
	{
		"title": "Card infos ingame",
		"videoPath": "res://data/videos/tutorial/5_cardInfosIngame.ogv",
		"desc": "You can also find these information while you're ingame. Just select a card and open up the information box on the left side."
	}
]
var KEY_TUT_DONE = "tutorialDone"

var currentPage = 0
func loadTutorialPage(index):
	if index < 0:
		index = 0
	elif index > tutorialPages.size():
		index = tutorialPages.size() - 1
	var tutorialPage = tutorialPages[index]
	var title = $Tutorial/Title as Label
	var vidPlayer = $Tutorial/VideoPlayer as VideoStreamPlayer
	var desc = $Tutorial/desc as RichTextLabel
	title.text = "Tutorial - " + tutorialPage["title"]
	var videoStream = load(tutorialPage["videoPath"]) as VideoStream
	vidPlayer.stream = videoStream
	desc.text = tutorialPage["desc"]
	vidPlayer.play()
	var backBtn = $Tutorial/Back as Button
	var nextBtn = $Tutorial/Next as Button
	backBtn.visible = true
	nextBtn.text = "Next"
	if index == 0:
		backBtn.visible = false
	if index == tutorialPages.size() - 1:
		nextBtn.text = "End"
		settings.setData(KEY_TUT_DONE, true)
		enableStartButton()
		onSettingsChanged()

func _on_tutorial_pressed():
	var tutPanel = $Tutorial as Panel
	tutPanel.visible = true
	currentPage = 0
	loadTutorialPage(currentPage)
	
func closeTutorialWindow():
	var tutPanel = $Tutorial as Panel
	tutPanel.visible = false
	
func _on_nextButton_pressed():
	currentPage += 1
	if currentPage >= tutorialPages.size():
		closeTutorialWindow()
	else:
		loadTutorialPage(currentPage)
	
func _on_backButton_pressed():
	currentPage -= 1
	loadTutorialPage(currentPage)

func _on_video_player_finished():
	var vidPlayer = $Tutorial/VideoPlayer as VideoStreamPlayer
	vidPlayer.play()
