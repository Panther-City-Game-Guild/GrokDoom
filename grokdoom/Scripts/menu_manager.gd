extends CanvasLayer

# Enum(s)
enum menuTypes { NONE, MAIN, DIFFICULTY, READY, SETTINGS }

# Variables
var menu := menuTypes.MAIN
var gameReady := false
var autoStartTime := 5.0
var time := 0.0
var timerRunning := false

# Menu Handles
@onready var menus: Dictionary[menuTypes, Control] = {
	menuTypes.MAIN: $TitleMenu,
	menuTypes.DIFFICULTY: $DifficultyMenu,
	menuTypes.READY: $ReadyMenu,
	menuTypes.SETTINGS: $SettingsWindow
}

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
	setMenu(menuTypes.MAIN) # Display the title menu
	setFocus() # Set the focus on an appropriate button


# Called when InputEvents are detected
func _input(event: InputEvent) -> void:
	if !event.is_pressed() && event.is_echo():
		return
	
	# If user just pressed "ui_cancel" (Escape)
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		# If the MainMenu is visible, decide which menu to display
		if visible:
			if LevelManager.inProgress:
				hide()
				get_tree().paused = false # Unpause the SceneTree
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				# BUG: When starting a new game while a game is running, closing the menu once does not unfreeze the mouse.  That could be from pausing the scene tree.
				return
			match menu:
				menuTypes.SETTINGS:
					Settings.saveSettings()
					setMenu(menuTypes.MAIN)
				menuTypes.DIFFICULTY:
					setMenu(menuTypes.MAIN)
				menuTypes.READY:
					timerRunning = false
					time = 0.0
					setMenu(menuTypes.DIFFICULTY)
		# If the MainMenu is not visible, show it
		else:
			show()
			setFocus()
			if LevelManager.inProgress:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				get_tree().paused = true # Pause the SceneTree
	
	# If user pressed "release_mouse" (BackSlash)( \ )
	if event.is_action_pressed("release_mouse"):
		get_viewport().set_input_as_handled()
		if LevelManager.inProgress: # Allow the user to release or capture the mouse as desired when a game is running
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: # If the mouse is captured, release it
				get_tree().paused = true
				show()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
			else: # If the mouse is loose, capture it
				get_tree().paused = false
				hide()
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every render frame
func _process(delta: float) -> void:
	# If the timer is running, see if it's run long enough
	if timerRunning:
		if time < autoStartTime:
			time += delta
			startingLabel.text = "Starting in " + str(roundi(autoStartTime - time)) + "..."
		else:
			# Emulate Start button being pressed (sort of)
			_on_StartButton_pressed()


func hideMenus() -> void:
	for item in menus.values():
		item.hide()


# Called to change which menu is actively being shown
func setMenu(option: menuTypes) -> void:
	menu = option
	hideMenus()
	match menu:
		menuTypes.MAIN:
			menus[menuTypes.MAIN].show()
		menuTypes.DIFFICULTY:
			menus[menuTypes.DIFFICULTY].show()
		menuTypes.READY:
			menus[menuTypes.READY].show()
		menuTypes.SETTINGS:
			menus[menuTypes.SETTINGS].show()
	setFocus()


# Called to find and set focus on ideal button
func setFocus() -> void:
	match menu:
		menuTypes.MAIN:
			newGameButton.grab_focus()
		menuTypes.DIFFICULTY:
			match Settings.last_difficulty:
				LevelManager.Difficulties.EASY:
					easyButton.grab_focus()
				LevelManager.Difficulties.NORMAL:
					normalButton.grab_focus()
				LevelManager.Difficulties.HARD:
					hardButton.grab_focus()
		menuTypes.READY:
			startButton.grab_focus()
		menuTypes.SETTINGS:
			menus[menuTypes.SETTINGS].grabFocus()


# Event Handler for when the NewGameButton gets pressed
func _on_NewGameButton_pressed():
	setMenu(menuTypes.DIFFICULTY)


# Event Handler for when the EasyButton gets pressed
func _on_EasyButton_pressed():
	Settings.last_difficulty = LevelManager.Difficulties.EASY
	gameReady = LevelManager.makeLevel()
	if gameReady:
		setMenu(menuTypes.READY)
		timerRunning = true


# Event Handler for when the MediumButton gets pressed
func _on_NormalButton_pressed():
	Settings.last_difficulty = LevelManager.Difficulties.NORMAL
	gameReady = LevelManager.makeLevel()
	if gameReady:
		setMenu(menuTypes.READY)
		timerRunning = true


# Event Handler for when the HardButton gets pressed
func _on_HardButton_pressed() -> void:
	Settings.last_difficulty = LevelManager.Difficulties.HARD
	gameReady = LevelManager.makeLevel()
	if gameReady:
		setMenu(menuTypes.READY)
		timerRunning = true


# Event Handler for when the StartButton gets pressed
func _on_StartButton_pressed() -> void:
	timerRunning = false
	time = 0.0
	setMenu(menuTypes.MAIN)
	hide()
	LevelManager.startGame()
	get_tree().paused = false # Unpause the SceneTree


func _on_SettingsButton_pressed() -> void:
	setMenu(menuTypes.SETTINGS)


# Event Handler for when the ExitButton gets pressed
func _on_ExitButton_pressed() -> void:	
	# Close the game
	get_tree().quit()


# Called when the CloseButton is pressed
func _on_CloseButton_pressed() -> void:
	Settings.saveSettings()
	setMenu(menuTypes.MAIN)
