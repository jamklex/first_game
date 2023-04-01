extends Node
class_name Settings

var _settingsData:Dictionary
var _settingsSavePath = "res://data/settings.json"

func _init():
	_loadData()
	
func getData(key):
	return _settingsData.get(key)
	
func setData(key, value):
	_settingsData[key] = value

func saveData():
	var file = FileAccess.open(_settingsSavePath, FileAccess.WRITE)
	file.store_line(JSON.stringify(_settingsData, "\t"))

func _loadData():
	if FileAccess.file_exists(_settingsSavePath):
		var file = FileAccess.open(_settingsSavePath, FileAccess.READ)
		_settingsData = JSON.parse_string(file.get_as_text())
		print("loaded settings from: " + ProjectSettings.globalize_path(_settingsSavePath))
	else:
		_settingsData = Dictionary()
		print("created settings")
