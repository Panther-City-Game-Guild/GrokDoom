extends Node

const SETTINGS_FILE := "user://settings.dat" # Settings file path
const DEBUG := true # Do I log debug lines?
enum VolumeTypes { MASTER, MUSIC, VOICE, SFX }

# Settings constraints
const MAX_VOLUME := 100.0 # Maximum volume setting
const MIN_VOLUME := 0.0 # Minimum volume setting
const MAX_MOUSELOOK := 1.3 # Maximum mouse look sensitivity
const MIN_MOUSELOOK := 0.1 # Minimum mouse look sensitivity
# Settings
var volumes: Dictionary[VolumeTypes, float] = {
	VolumeTypes.MASTER: 70.0, # Default value should be mid-high so players can hear without being overwhelmed
	VolumeTypes.MUSIC: 20.0, # Keep default music low to not hurt players on first load
	VolumeTypes.VOICE: 50.0, # Default mid range
	VolumeTypes.SFX: 60.0 # Default mid-high
}
var mouse_look := 0.5 # Default to MIN value
var last_difficulty := LevelManager.Difficulties.NORMAL # Level Difficulty: Default to Normal
var enemy_to_use := Enemy.EnemyTypes.CAPSULE # Which type of enemies to load


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	if FileAccess.file_exists(SETTINGS_FILE):
		loadSettings() # If a settings file exists, load the saved settings
	else:
		saveSettings() # Otherwise, create a settings file for the next time


# Called to load the saved settings
func loadSettings() -> void:
	var file := FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	# DATA VALIDATION
	# Set volumes
	if data.has("volumes"):
		var dataDup = {}
		for i in data.volumes.keys(): # Convert keys in data to integers
			dataDup[int(i)] = data.volumes[i]
		
		if dataDup.has(VolumeTypes.MASTER): # Master
			print("data has volumes.master")
			if typeof(dataDup[VolumeTypes.MASTER]) == TYPE_FLOAT && dataDup[VolumeTypes.MASTER] >= MIN_VOLUME && dataDup[VolumeTypes.MASTER] <= MAX_VOLUME:
				volumes[VolumeTypes.MASTER] = dataDup[VolumeTypes.MASTER] # If incoming value is a float between MIN and MAX, set it!
		
		if dataDup.has(VolumeTypes.MUSIC): # Music
			print("data has volumes.music")
			if typeof(dataDup[VolumeTypes.MUSIC]) == TYPE_FLOAT && dataDup[VolumeTypes.MUSIC] >= MIN_VOLUME && dataDup[VolumeTypes.MUSIC] <= MAX_VOLUME:
				volumes[VolumeTypes.MUSIC] = dataDup[VolumeTypes.MUSIC] # If incoming value is a float between MIN and MAX, set it!
		
		if dataDup.has(VolumeTypes.VOICE): # Voices
			print("data has volumes.voice")
			if typeof(dataDup[VolumeTypes.VOICE]) == TYPE_FLOAT && dataDup[VolumeTypes.VOICE] >= MIN_VOLUME && dataDup[VolumeTypes.VOICE] <= MAX_VOLUME:
				volumes[VolumeTypes.VOICE] = dataDup[VolumeTypes.VOICE] # If incoming value is a float between MIN and MAX, set it!
		
		if dataDup.has(VolumeTypes.SFX): # Sound FX
			print("data has volumes.sfx")
			if typeof(dataDup[VolumeTypes.SFX]) == TYPE_FLOAT && dataDup[VolumeTypes.SFX] >= MIN_VOLUME && dataDup[VolumeTypes.SFX] <= MAX_VOLUME:
				volumes[VolumeTypes.SFX] = dataDup[VolumeTypes.SFX] # If incoming value is a float between MIN and MAX, set it!
	
	# Set mouse_look
	if data.has("mouse_look"):
		if typeof(data.mouse_look) == TYPE_FLOAT && data.mouse_look >= MIN_MOUSELOOK && mouse_look <= MAX_MOUSELOOK:
			mouse_look = data.mouse_look # If incoming value is a float between 0.5 and 1.25, set it!
	
	# Set the last_difficulty
	if data.has("last_difficulty"):
		for type in LevelManager.Difficulties.values():
			if data.last_difficulty == type:
				last_difficulty = data.last_difficulty
	
	if data.has("enemy_to_use"):
		for type in Enemy.EnemyTypes.values():
			if data.enemy_to_use == type:
				enemy_to_use = data.enemy_to_use
	
	if data && DEBUG:
		printSettingsParse(data)


# Called to save the current settings
func saveSettings() -> void:
	var file := FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	var data := {
		"volumes" = volumes.duplicate(),
		"mouse_look" = mouse_look,
		"last_difficulty" = last_difficulty,
		"enemy_to_use" = enemy_to_use
	}
	
	file.store_string(JSON.stringify(data))
	file.close()
	if data && DEBUG:
		print("Settings: Data saved: ", JSON.stringify(data))


func printSettingsParse(data) -> void:
	print("Settings: Data loaded: ", data)
	print("Settings: Volumes: ", volumes)
	print("Settings: Mouse Look: ", mouse_look)
	print("Settings: Last Difficulty: ", last_difficulty)
	print("Settings: Enemy To Use: ", enemy_to_use)
