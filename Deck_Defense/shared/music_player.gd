extends Node

var _audioStreamPlayer:AudioStreamPlayer
var _newTrack:AudioStreamMP3
const MUSIC_FOLDER = "res://data/music/"
const START_AUDIO_VOLUME = 50
var volume = START_AUDIO_VOLUME
var _curDb = -100

func _ready():
	_audioStreamPlayer = AudioStreamPlayer.new()
	setVolume(volume)
	_audioStreamPlayer.autoplay = true
	_audioStreamPlayer.finished.connect(_restartMusic)
#	_fadeTween = create_tween()
	add_child(_audioStreamPlayer)
	
func setVolume(newVolumeInPercent):
	volume = newVolumeInPercent
	_curDb = (volume / 100.0 * 60) - 60
	_audioStreamPlayer.volume_db = _curDb
	
func _restartMusic():
	_audioStreamPlayer.play()

func switchMusic(newMusicPath):
	_newTrack = load(MUSIC_FOLDER + newMusicPath)
	if not _newTrack:
		return
	switchFade()
		
func switchFade():
	var fadeTween = create_tween()
	fadeTween.tween_property(_audioStreamPlayer, "volume_db", -60.0, 0.5)
	fadeTween.tween_callback(startNewMusic)
	fadeTween.tween_property(_audioStreamPlayer, "volume_db", _curDb, 0.5)	
	
func startNewMusic():
	_audioStreamPlayer.stream = _newTrack
	_audioStreamPlayer.play()
