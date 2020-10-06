extends Node


func _ready():
	randomize()


func roll(dice_sides):
	var return_value = randi() % dice_sides + 1
	return return_value


func stat_roll():
	var rolls = []
	for _i in range(4):
		rolls.append(roll(6))
	
	var max_value = 6
	var lowest_value_index = 0
	
	for i in range(4):
		if rolls[i] < max_value:
			max_value = rolls[i]
			lowest_value_index = i
	
	var score_value = 0
	
	for i in range(4):
		if i != lowest_value_index:
			score_value += rolls[i]
	
	return score_value


func mod_calculate(stat):
	return floor((stat - 10) / 2)
