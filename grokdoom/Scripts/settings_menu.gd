extends Panel

# Volume Group Handles
@onready var volumeGroups: Dictionary[Settings.VolumeTypes, Panel] = {
	Settings.VolumeTypes.MASTER: $Tabs/Sound/Master,
	Settings.VolumeTypes.MUSIC: $Tabs/Sound/Music,
	Settings.VolumeTypes.VOICE: $Tabs/Sound/Voice,
	Settings.VolumeTypes.SFX: $Tabs/Sound/SFX
}

# Volume Slider Handles
@onready var volumeSliders: Dictionary[Settings.VolumeTypes, HSlider] = {
	Settings.VolumeTypes.MASTER: $Tabs/Sound/Master/HSlider,
	Settings.VolumeTypes.MUSIC: $Tabs/Sound/Music/HSlider,
	Settings.VolumeTypes.VOICE: $Tabs/Sound/Voice/HSlider,
	Settings.VolumeTypes.SFX: $Tabs/Sound/SFX/HSlider
}

# Volume Value Label Handles
@onready var volumeHints: Dictionary[Settings.VolumeTypes, Label]= {
	Settings.VolumeTypes.MASTER: $Tabs/Sound/Master/Volume,
	Settings.VolumeTypes.MUSIC: $Tabs/Sound/Music/Volume,
	Settings.VolumeTypes.VOICE: $Tabs/Sound/Voice/Volume,
	Settings.VolumeTypes.SFX: $Tabs/Sound/SFX/Volume
}
@onready var volumeGroupHint := $Tabs/Sound/VolumeHint # Control Group Hint Handle
@onready var closeButton := $CloseButton # CloseButton Handle
@onready var enemyTypeButton := $Tabs/AI/EnemyTypes/OptionButton
@onready var mouseLookSlider := $Tabs/Controls/MouseGroup/HSlider
@onready var mouseLookSpeed := $Tabs/Controls/MouseGroup/Speed



# Called when the node enters the scene tree for the first time
func _ready() -> void:
	connectSignals() # Connect child node signals to appropriate functions
	loadValues() # Load default or saved settings from Settings
	
# Called when InputEvents are detected
func _input(event: InputEvent) -> void:
	if visible: # Only detect input events when this window is visible
		if !event.is_pressed() || event.is_echo():
			return
		
		if event.is_action("ui_cancel"):
			get_viewport().set_input_as_handled() # Prevent other windows from processing this input
			on_CloseButtonPressed() # Save settings and close SettingsWindow

# Called to load values at application start
func loadValues() -> void:
	mouseLookSlider.max_value = Settings.MAX_MOUSELOOK
	mouseLookSlider.min_value = Settings.MIN_MOUSELOOK
	mouseLookSlider.value = Settings.mouse_look
	mouseLookSpeed.text = str(Settings.mouse_look)
	
	for i: int in volumeSliders.size():
		volumeSliders[i].max_value = Settings.MAX_VOLUME
		volumeSliders[i].min_value = Settings.MIN_VOLUME
		volumeSliders[i].value = Settings.volumes[i]
		volumeHints[i].text = str(Settings.volumes[i])
	
	# Create options in OptionButton
	for key in Enemy.EnemyTypes.keys():
		enemyTypeButton.add_item(key, Enemy.EnemyTypes[key])
	enemyTypeButton.select(Settings.enemy_to_use)
	enemyTypeButton.item_selected.connect(on_EnemyTypeChanged)


# Called to connect node signals at application start
func connectSignals() -> void:
	closeButton.pressed.connect(on_CloseButtonPressed)
	mouseLookSlider.value_changed.connect(on_MouseLookChange)
	for i in volumeGroups.size():
		volumeGroups[i].mouse_entered.connect(on_MouseEnteredVolumeGroup.bind(i))
		volumeGroups[i].mouse_exited.connect(on_MouseExitedVolumeGroup)
		
		var slider: HSlider = volumeGroups[i].get_node("./HSlider")
		slider.mouse_entered.connect(on_MouseEnteredVolumeGroup.bind(i))
		slider.mouse_exited.connect(on_MouseExitedVolumeGroup)
		slider.value_changed.connect(on_VolumeSliderChange.bind(i))


# Called when the mouse hovers a control group or a volume slider
func on_MouseEnteredVolumeGroup(group) -> void:
	match group:
		Settings.VolumeTypes.MASTER:
			volumeGroupHint.text = "Adjusting this affects volume for Music, Voices, and Sound Effects."
		Settings.VolumeTypes.MUSIC:
			volumeGroupHint.text = "Adjusting this affects volume for background music."
		Settings.VolumeTypes.VOICE:
			volumeGroupHint.text = "Adjusting this affects volume for grunts, groans, screams, and voiceovers."
		Settings.VolumeTypes.SFX:
			volumeGroupHint.text = "Adjusting this affects volume for sounds like foot steps, weapon fire, and power-up collection."


# Called when the mouse un-hovers a control group or a volume slider
func on_MouseExitedVolumeGroup() -> void:
	volumeGroupHint.text = ""


# Called when a volume slider value is changed
func on_VolumeSliderChange(value: float, groupNum: int) -> void:
	Settings.volumes[groupNum] = value
	volumeHints[groupNum].text = str(value)


# Called when the user updates the value of the Mouse Look Slider
func on_MouseLookChange(value: float) -> void:
	Settings.mouse_look = value
	mouseLookSpeed.text = str(value)


# Called when the user changes the selected item of EnemyTypes Button
func on_EnemyTypeChanged(index: int) -> void:
	Settings.enemy_to_use = index as Enemy.EnemyTypes


# Called to tell this window which Control to focus on when opened
func grabFocus() -> void:
	if self.visible:
		closeButton.grab_focus()

# Called when the CloseButton is pressed
func on_CloseButtonPressed() -> void:
	Settings.saveSettings()
	MenuManager.setMenu(MenuManager.menuTypes.MAIN)
