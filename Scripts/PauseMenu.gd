extends CanvasLayer

@onready var resume_btn = $VBoxContainer/Resume
@onready var main_menu_btn = $VBoxContainer/MainMenu
@onready var quit_btn = $VBoxContainer/Quit

func _ready() -> void:
	# Hide menu at start
	visible = false
	
	resume_btn.pressed.connect(_on_resume_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	# Check for ESC key (ui_cancel is mapped to ESC by default)
	if event.is_action_pressed("esc"):
		toggle_pause()

func toggle_pause() -> void:
	# Flip the visible state
	visible = not visible
	
	# PAUSE THE GAME
	get_tree().paused = visible

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_main_menu_pressed() -> void:
	# IMPORTANT: Unpause before changing scenes, or the Main Menu will be stuck!
	toggle_pause() 
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
