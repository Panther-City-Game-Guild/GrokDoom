extends Panel

# Control Group Types
enum groups {
	MASTERGROUP,
	MUSICGROUP,
	VOICEGROUP,
	SFXGROUP
}

# Control Group Handles
@onready var controlGroups := [ $MasterGroup, $MusicGroup, $VoiceGroup, $SFXGroup ]

# Volume Slider Handles
@onready var sliders := [ $MasterGroup/HSlider, $MusicGroup/HSlider, $VoiceGroup/HSlider, $SFXGroup/HSlider ]

# Volume Hint Handles
@onready var volumeHints := [ $MasterGroup/Volume, $MusicGroup/Volume, $VoiceGroup/Volume, $SFXGroup/Volume ]

# Control Group Hint Handle
@onready var groupHint := $GroupHint

# CloseButton Handle
@onready var closeButton := $CloseButton


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	loadValues() # Load default or saved settings from SettingsManager
	connectSignals() # Connect child node signals to appropriate functions


# Called to load values at application start
func loadValues() -> void:
	for i in volumeHints.size():
		match i as groups:
			groups.MASTERGROUP:
				sliders[i].value = SettingsManager.master_volume
				volumeHints[i].text = str(SettingsManager.master_volume)
			groups.MUSICGROUP:
				sliders[i].value = SettingsManager.music_volume
				volumeHints[i].text = str(SettingsManager.music_volume)
			groups.VOICEGROUP:
				sliders[i].value = SettingsManager.voices_volume
				volumeHints[i].text = str(SettingsManager.voices_volume)
			groups.SFXGROUP:
				sliders[i].value = SettingsManager.sfx_volume
				volumeHints[i].text = str(SettingsManager.sfx_volume)


# Called to connect node signals at application start
func connectSignals() -> void:
	for i in controlGroups.size():
		controlGroups[i].mouse_entered.connect(on_MouseEntered_group.bind(i))
		controlGroups[i].mouse_exited.connect(on_MouseExited_group)
		
		var groupSlider: HSlider = controlGroups[i].get_node("./HSlider")
		groupSlider.mouse_entered.connect(on_MouseEntered_group.bind(i))
		groupSlider.mouse_exited.connect(on_MouseExited_group)
		groupSlider.value_changed.connect(on_SliderChange.bind(i))


# Called when the mouse hovers a control group or a volume slider
func on_MouseEntered_group(group) -> void:
	match group:
		groups.MASTERGROUP:
			groupHint.text = "Adjusting this affects volume for Music, Voices, and Sound Effects."
		groups.MUSICGROUP:
			groupHint.text = "Adjusting this affects volume for background music."
		groups.VOICEGROUP:
			groupHint.text = "Adjusting this affects volume for grunts, groans, screams, and voiceovers."
		groups.SFXGROUP:
			groupHint.text = "Adjusting this affects volume for sounds like foot steps, weapon fire, and power-up collection."


# Called when the mouse un-hovers a control group or a volume slider
func on_MouseExited_group() -> void:
	groupHint.text = ""


# Called when a volume slider value is changed
func on_SliderChange(value: float, groupNum: int) -> void:
	print(groups.find_key(groupNum), " Slider value changed: ", value)
	volumeHints[groupNum].text = str(value)
	match groupNum as groups:
		groups.MASTERGROUP:
			SettingsManager.master_volume = value
		groups.MUSICGROUP:
			SettingsManager.music_volume = value
		groups.VOICEGROUP:
			SettingsManager.voices_volume = value
		groups.SFXGROUP:
			SettingsManager.sfx_volume = value


func grabFocus() -> void:
	if self.visible:
		closeButton.grab_focus()
