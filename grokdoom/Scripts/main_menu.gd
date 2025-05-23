extends Control

# Signal(s)
#signal StartGame

# Enum(s)
enum menus {
	TITLE,
	DIFFICULTY,
	READY,
	SETTINGS
}

# Variables
var menu := menus.TITLE
var lastMenu := menus.TITLE
var gameReady := false
var autoStartTime := 5.0
var time := 0.0
var timerRunning := false

# Menu Handles
@onready var titleMenu := $TitleMenu
@onready var difficultyMenu := $DifficultyMenu
@onready var readyMenu := $ReadyMenu
@onready var settingsMenu := $SettingsMenu

# Menu Buttons & Label(s) Handles
@onready var newGameButton := $TitleMenu/NewGameButton
@onready var easyButton := $DifficultyMenu/EasyButton
@onready var normalButton := $DifficultyMenu/NormalButton
@onready var hardButton := $DifficultyMenu/HardButton
@onready var startButton := $ReadyMenu/StartButton
@onready var startingLabel := $ReadyMenu/StartingLabel


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS # Set this node so it does not stop processing (useful for pausing/unpausing the game)
	setMenu(menus.TITLE) # Display the title menu
	setFocus() # Set the focus on an appropriate button


# Called every render frame
func _process(delta: float) -> void:
	# If user just pressed "ui_cancel" (Escape)
	if Input.is_action_just_pressed("ui_cancel"):
		# If the MainMenu is visible, decide which menu to display
		if self.visible:
			if LevelManager.inProgress:
				hideMenu()
				get_tree().paused = false # Unpause the SceneTree
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				# BUG: When starting a new game while a game is running, closing the menu once does not unfreeze the mouse.  That could be from pausing the scene tree.
				return
			match menu:
				menus.SETTINGS:
					SettingsManager.saveSettings()
					setMenu(menus.TITLE)
				menus.DIFFICULTY:
					setMenu(menus.TITLE)
				menus.READY:
					timerRunning = false
					time = 0.0
					setMenu(menus.DIFFICULTY)
		# If the MainMenu is not visible, show it
		else:
			showMenu()
			setFocus()
			if LevelManager.inProgress:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				get_tree().paused = true # Pause the SceneTree


	
	# If the timer is running, see if it's run long enough
	if timerRunning:
		if time < autoStartTime:
			time += delta
			startingLabel.text = "Starting in " + str(roundi(autoStartTime - time)) + "..."
		else:
			# Emulate Start button being pressed (sort of)
			_on_StartButton_pressed()


# Called to hide the Main Menu
func hideMenu() -> void:
	self.visible = false


# Called to show the Main Menu
func showMenu() -> void:
	self.visible = true


# Called to change which menu is actively being shown
func setMenu(option) -> void:
	menu = option as menus
	match menu:
		menus.TITLE:
			titleMenu.visible = true
			difficultyMenu.visible = false
			readyMenu.visible = false
			settingsMenu.visible = false
		menus.DIFFICULTY:
			titleMenu.visible = false
			difficultyMenu.visible = true
			readyMenu.visible = false
			settingsMenu.visible = false
		menus.READY:
			titleMenu.visible = false
			difficultyMenu.visible = false
			readyMenu.visible = true
			settingsMenu.visible = false
		menus.SETTINGS:
			titleMenu.visible = false
			difficultyMenu.visible = false
			readyMenu.visible = false
			settingsMenu.visible = true
	setFocus()


# Called to find and set focus on ideal button
func setFocus() -> void:
	match menu:
		menus.TITLE:
			newGameButton.grab_focus()
		menus.DIFFICULTY:
			match SettingsManager.last_difficulty:
				LevelManager.difficulties.EASY:
					easyButton.grab_focus()
				LevelManager.difficulties.NORMAL:
					normalButton.grab_focus()
				LevelManager.difficulties.HARD:
					hardButton.grab_focus()
		menus.READY:
			startButton.grab_focus()
		menus.SETTINGS:
			settingsMenu.grabFocus()


# Event Handler for when the NewGameButton gets pressed
func _on_NewGameButton_pressed():
	setMenu(menus.DIFFICULTY)


# Event Handler for when the EasyButton gets pressed
func _on_EasyButton_pressed():
	SettingsManager.last_difficulty = LevelManager.difficulties.EASY
	LevelManager.difficulty = LevelManager.difficulties.EASY
	gameReady = LevelManager.makeLevel()
	if gameReady:
		setMenu(menus.READY)
		timerRunning = true


# Event Handler for when the MediumButton gets pressed
func _on_NormalButton_pressed():
	SettingsManager.last_difficulty = LevelManager.difficulties.NORMAL
	LevelManager.difficulty = LevelManager.difficulties.NORMAL
	gameReady = LevelManager.makeLevel()
	if gameReady:
		setMenu(menus.READY)
		timerRunning = true


# Event Handler for when the HardButton gets pressed
func _on_HardButton_pressed() -> void:
	SettingsManager.last_difficulty = LevelManager.difficulties.HARD
	LevelManager.difficulty = LevelManager.difficulties.HARD
	gameReady = LevelManager.makeLevel()
	if gameReady:
		setMenu(menus.READY)
		timerRunning = true


# Event Handler for when the StartButton gets pressed
func _on_StartButton_pressed() -> void:
	timerRunning = false
	time = 0.0
	setMenu(menus.TITLE)
	hideMenu()
	LevelManager.startGame()
	get_tree().paused = false # Unpause the SceneTree


func _on_SettingsButton_pressed() -> void:
	setMenu(menus.SETTINGS)


# Event Handler for when the ExitButton gets pressed
func _on_ExitButton_pressed() -> void:	
	# Close the game
	get_tree().quit()


# Called when the CloseButton is pressed
func _on_CloseButton_pressed() -> void:
	SettingsManager.saveSettings()
	setMenu(menus.TITLE)
