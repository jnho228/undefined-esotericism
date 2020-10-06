extends Node


var player_level = 1
var crystals_collected = 0

onready var player_str = DiceRoller.stat_roll()
onready var player_dex = DiceRoller.stat_roll()
onready var player_con = DiceRoller.stat_roll()
onready var player_int = DiceRoller.stat_roll()
onready var player_wis = DiceRoller.stat_roll()

onready var player_max_health = 8 + player_con
onready var player_current_health = player_max_health
var player_exp_to_level = 100
var player_current_exp = 0
var player_weapon

var dialogue_text = []


func clear_data():
	player_level = 1
	crystals_collected = 0
	
	player_str = DiceRoller.stat_roll()
	player_dex = DiceRoller.stat_roll()
	player_con = DiceRoller.stat_roll()
	player_int = DiceRoller.stat_roll()
	player_wis = DiceRoller.stat_roll()
	
	player_max_health = 8 + player_con
	player_current_health = player_max_health
	player_exp_to_level = 100
	player_current_exp = 0
	player_weapon = null
	
	dialogue_text = []
