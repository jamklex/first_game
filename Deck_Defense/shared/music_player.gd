extends Node

var _audioStreamPlayer:AudioStreamPlayer
var _newTrack:AudioStreamMP3
const MUSIC_FOLDER = "res://data/music/"

func _ready():
	_audioStreamPlayer = AudioStreamPlayer.new()
	_audioStreamPlayer.volume_db = 1.0
	_audioStreamPlayer.autoplay = true
	_audioStreamPlayer.volume_db
#	_fadeTween = create_tween()
	add_child(_audioStreamPlayer)
	

func switchMusic(newMusicPath):
	_newTrack = _loadMp3(newMusicPath)
	if not _newTrack:
		return
	switchFade()
		
func switchFade():
	var fadeTween = create_tween()
	fadeTween.tween_property(_audioStreamPlayer, "volume_db", -80.0, 2)
	fadeTween.tween_callback(startNewMusic)
	fadeTween.tween_property(_audioStreamPlayer, "volume_db", 0, 2)	
	
func startNewMusic():
	_audioStreamPlayer.stream = _newTrack
	_audioStreamPlayer.play()
	
func _loadMp3(musicFileName):
	var musicPath = MUSIC_FOLDER + musicFileName
	if not FileAccess.file_exists(musicPath):
		return null
	var file = FileAccess.open(musicPath, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	print(sound.get_length())
	return sound
