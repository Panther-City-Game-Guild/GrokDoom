extends Node

# Settings file path
const SETTINGS_FILE := "user://settings.dat"
const DEBUG := true

# Volume Settings
var master_volume := 70.0
var music_volume := 20.0
var voices_volume := 50.0
var sfx_volume := 30.0
var mouse_look_sensitivity := 1.0
var last_difficulty := LevelManager.difficulty


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# If a settings file exists, load the saved settings
	if FileAccess.file_exists(SETTINGS_FILE):
		loadSettings()
	# Otherwise, create a settings file for the next time
	else:
		saveSettings()


# Called to load the saved settings
func loadSettings() -> void:
	var file := FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	
	if data && DEBUG:
		print("Settings loaded: ", data)
	file.close()
	
	# DATA VALIDATION
	# Set master_volume
	if data.has("master_volume"):
		if data.master_volume <= 100:
			master_volume = data.master_volume
	
	# Set music_volume
	if data.has("music_volume"):
		if data.music_volume <= 100:
			music_volume = data.music_volume
		
	# Set voices_volume
	if data.has("voices_volume"):
		if data.voices_volume <= 100:
			voices_volume = data.voices_volume
		
	# Set sfx_volume
	if data.has("sfx_volume"):
		if data.sfx_volume <= 100:
			sfx_volume = data.sfx_volume
			
	# Set mouse_look_sensitivity
		if data.has("mouse_look_sensitivity"):
			if data.mouse_look_sensitivity > 0.0 && mouse_look_sensitivity <= 10.0:
				mouse_look_sensitivity = data.mouse_look_sensitivity
		
	# Set the last_difficulty
	if data.has("last_difficulty"):
		if data.last_difficulty == LevelManager.difficulties.EASY || data.last_difficulty == LevelManager.difficulties.NORMAL || data.last_difficulty == LevelManager.difficulties.HARD:
			last_difficulty = data.last_difficulty


# Called to save the current settings
func saveSettings() -> void:
	var file := FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	var data := {
		"master_volume" = master_volume,
		"music_volume" = music_volume,
		"voices_volume" = voices_volume,
		"sfx_volume" = sfx_volume,
		"mouse_look_sensitivity" = mouse_look_sensitivity,
		"last_difficulty" = last_difficulty
	}
	
	file.store_string(JSON.stringify(data))
	file.close()
	if data && DEBUG:
		print("Settings saved: ", data)
