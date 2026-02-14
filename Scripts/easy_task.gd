extends TextureButton

const CLICK_SOUND = preload("res://Assets/Audio/Click Sound.mp3")
const HOVER_SOUND = preload("res://Assets/Audio/hover sound.mp3")

@onready var label = $Label
func _ready() -> void:
	# Connect the mouse signals to our functions
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)

func _on_hover() -> void:
	# Darken the button (0.8, 0.8, 0.8 is dark gray)
	if label: 
		label.visible_ratio = 0.0
		var tween = create_tween()
		tween.tween_property(label, "visible_ratio", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	modulate = Color(0.8, 0.8, 0.8)
	AudioManager.play_sfx(HOVER_SOUND)

func _on_exit() -> void:
	# Reset to normal full color (White means "no tint")
	modulate = Color(1, 1, 1)


func _on_pressed() -> void:
	AudioManager.play_sfx(CLICK_SOUND)
	GameData.player_level = 1
	GameData.rooms_cleared = 0
	GameData.player_current_health = GameData.player_max_health
	get_tree().change_scene_to_file("res://Scenes/StoryScene.tscn")
