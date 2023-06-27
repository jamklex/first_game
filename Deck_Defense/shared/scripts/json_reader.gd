extends Node

const StartPlayerData = "res://data/player.json"
const PlayerData = "user://player"
const EnemyData = "res://data/enemies/%s.json"
const PackagePath = "res://data/packs/%s"
const Pass = "asd2d54JUH"

var cache = {}

func read_json_cached(path):
	if not cache.has(path):
		cache[path] =  read_json(path)
	return cache[path]

func read_json(path, encrypted = false):
	print(path)
	var file = null 
	if encrypted:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, Pass)
	else:
		file = FileAccess.open(path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())
	
func save_json(path, json, encrypted = false):
	var file = null
	if encrypted:
		file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, Pass)
	else:
		file = FileAccess.open(path, FileAccess.WRITE)
	file.store_line(JSON.stringify(json, '\t'))
	file.flush()
	file.close()

func read_player_data():
	if not FileAccess.file_exists(PlayerData):
		initStartPlayerData()
	return read_json(PlayerData, true)
	
func save_player_data(playerDataJson):
	return save_json(PlayerData, playerDataJson, true)

func initStartPlayerData():
	save_json(PlayerData, read_json(StartPlayerData), true)

func read_enemy_data(level):
	return read_json(EnemyData % level)
	
func save_enemy_data(level, enemyDataJson):
	return save_json(EnemyData % level, enemyDataJson)

func package_paths():
	var files = []
	var dir = DirAccess.open(PackagePath % "")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".json"):
				files.append(PackagePath % file_name)
			file_name = dir.get_next()
	return files
