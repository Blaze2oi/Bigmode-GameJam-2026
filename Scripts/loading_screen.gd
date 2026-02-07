extends Control

func _ready() -> void:
	# Priority 1: Check for manual text overrides (Failure/Victory)
	if GameData.loading_text_override != "":
		$Label.text = GameData.loading_text_override
		GameData.loading_text_override = "" # Reset it for next time
	# Priority 2: Standard Room Logic
	elif GameData.is_next_boss:
		$Label.text = "FINAL ROOM"
	else:
		$Label.text = "ROOM " + str(GameData.rooms_cleared + 1)
		
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file(GameData.next_room_path)
