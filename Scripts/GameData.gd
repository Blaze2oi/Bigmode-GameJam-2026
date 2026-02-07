extends Node

# Player Stats
var player_health: int = 100
var player_stamina: float = 100.0
var player_money: int = 0
var player_attack: int = 20
var player_level: int = 1

# Dungeon Progression
var rooms_cleared: int = 0
var room_order: Array = [] # Stores paths like ["res://dungeon_room_2.tscn", "res://dungeon_room_1.tscn"]
var next_room_path: String = ""
var is_next_boss: bool = false
var loading_text_override: String = ""
