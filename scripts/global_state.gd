extends Node

# Persistent Data Management
# This script handles all global variables and shared state
# Built for "Echoes of the Abyss"

# ========================================
# Resources
# ========================================
var current_gold: int = 0

# ========================================
# Win Condition
# ========================================
const WIN_GOLD_REQUIRED: int = 1000

# Adding a simple print to verify it loaded
func _ready() -> void:
	print("GlobalState initialized.")
