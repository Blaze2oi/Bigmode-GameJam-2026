extends Control

@onready var money_label = $"4/Label"

func _ready():
	update_ui()
	$VBoxContainer/Health.pressed.connect(_buy_health)
	$VBoxContainer/Attack.pressed.connect(_buy_attack)
	$VBoxContainer/Cooldown.pressed.connect(_buy_speed)
	$VBoxContainer/NextDel.pressed.connect(_go_to_next_selection)
	

func update_ui():
	money_label.text = str(GameData.player_money)

func _buy_health():
	if GameData.player_money >= 150:
		GameData.player_money -= 150
		GameData.player_max_health += 20  # Upgrade the limit
		GameData.player_current_health = GameData.player_max_health # Heal to full
		update_ui()

func _buy_attack():
	if GameData.player_money >= 150:
		GameData.player_money -= 150
		GameData.player_attack += 20
		update_ui()

func _buy_speed():
	if GameData.player_money >= 100:
		GameData.player_money -= 100
		# Lower cooldown is better/faster
		GameData.player_attack_cooldown = max(0.1, GameData.player_attack_cooldown - 0.05)
		update_ui()

func _go_to_next_selection():
	# Go back to start another round of delivery selection
	get_tree().change_scene_to_file("res://Scenes/delivery_selection.tscn")
