extends Node

const PlayerData = "res://data/player.json"
const EnemyData = "res://data/enemies/%s.json"
const PackagePath = "res://data/packs/%s"

func read_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func read_player_data():
	return read_json(PlayerData)

func read_enemy_data(level):
	return read_json(EnemyData % level)

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

func add_player_cards(cards_for_player):
	print("should add " + str(cards_for_player) + " to player cards")
	pass
