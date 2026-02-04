extends Control

# --- ANIMATION & PAGES ---
@onready var book_anim = $BookBackground
@onready var main_page = $MainPage
@onready var options_page = $OptionsPage

var bar_start_percent: float = 30.0  # Where the pips start visually (0-100)
var bar_end_percent: float = 65.0    # Where the pips end visually (0-100)
# --- NEW VOLUME NODES ---
# Make sure these paths match your Scene Tree! 
# (e.g., OptionsPage -> TextureRect -> HBoxContainer -> Nodes)
@onready var volume_bar = $OptionsPage/TextureRect/HBoxContainer/VolumeBar
@onready var percent_label = $OptionsPage/TextureRect/HBoxContainer/PercentLabel
@onready var btn_down = $OptionsPage/TextureRect/HBoxContainer/BtnDown
@onready var btn_up = $OptionsPage/TextureRect/HBoxContainer/BtnUp

# Volume Variables
var current_vol: float = 1.0
var step: float = 0.05

func _ready() -> void:
	# 1. Ensure starting state
	book_anim.visible = false
	main_page.visible = true
	options_page.visible = false
	
	# 2. Connect Navigation Buttons
	$MainPage/VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$OptionsPage/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	
	# 3. Connect Volume Buttons (NEW)
	btn_down.pressed.connect(_on_volume_down)
	btn_up.pressed.connect(_on_volume_up)
	
	# 4. Initialize Volume Display
	var bus_index = AudioServer.get_bus_index("Master")
	current_vol = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	update_volume_display()

# --- NEW VOLUME LOGIC ---
func _on_volume_up() -> void:
	change_volume(step)

func _on_volume_down() -> void:
	change_volume(-step)

func change_volume(amount: float) -> void:
	# Clamp ensures we don't go below 0% or above 100%
	current_vol = clamp(current_vol + amount, 0.0, 1.0)
	
	var bus_index = AudioServer.get_bus_index("Master")
	
	# Mute if 0 (optional polish)
	AudioServer.set_bus_mute(bus_index, current_vol <= 0.01)
	
	# Convert linear (0-1) to dB for natural sound scaling
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(current_vol))
	
	update_volume_display()

func update_volume_display() -> void:
	# 1. Map the 0.0-1.0 volume to the 30-65 visual range
	# lerp(min, max, weight) calculates the value between min and max
	var visual_value = lerp(bar_start_percent, bar_end_percent, current_vol)
	
	# 2. Apply it to the bar
	volume_bar.value = visual_value
	
	# 3. Update the text label (keep this normal 0-100%)
	percent_label.text = str(round(current_vol * 100)) + "%"

# --- PAGE TURN LOGIC (Unchanged) ---
func _on_options_pressed() -> void:
	set_buttons_active(false)
	
	var tween = create_tween()
	tween.tween_property(main_page, "modulate:a", 0.0, 0.2)
	await tween.finished
	main_page.visible = false
	book_anim.visible = true
	
	book_anim.play("next")
	await book_anim.animation_finished
	book_anim.visible = false
	
	options_page.modulate.a = 0.0
	options_page.visible = true
	
	var tween_in = create_tween()
	tween_in.tween_property(options_page, "modulate:a", 1.0, 0.3)
	await tween_in.finished
	
	set_buttons_active(true)

func _on_back_pressed() -> void:
	set_buttons_active(false)
	
	var tween = create_tween()
	tween.tween_property(options_page, "modulate:a", 0.0, 0.2)
	await tween.finished
	options_page.visible = false
	book_anim.visible = true
	
	book_anim.play("prev")
	await book_anim.animation_finished
	book_anim.visible = false
	
	main_page.modulate.a = 0.0
	main_page.visible = true
	
	var tween_in = create_tween()
	tween_in.tween_property(main_page, "modulate:a", 1.0, 0.3)
	await tween_in.finished
	
	set_buttons_active(true)

func set_buttons_active(is_active: bool) -> void:
	if is_active:
		main_page.process_mode = Node.PROCESS_MODE_INHERIT
		options_page.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		main_page.process_mode = Node.PROCESS_MODE_DISABLED
		options_page.process_mode = Node.PROCESS_MODE_DISABLED
