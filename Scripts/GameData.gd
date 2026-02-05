extends Node

# Player Stats
var player_health: int = 100
var player_stamina: float = 100.0
var player_money: int = 0
var player_attack: int = 20
var player_level: int = 1
var player_Exp: int = 0
var player_MaxExp: int =100

# Dungeon Progression
var rooms_cleared: int = 0
var room_order: Array = [] # Stores paths like ["res://dungeon_room_2.tscn", "res://dungeon_room_1.tscn"]
