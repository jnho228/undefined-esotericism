extends Area2D


export (Array, AudioStreamSample) var sound_effects

export var hit_die_value = 8
var target

var strength = 0
var dexterity = 0
var constitution = 0
var intelligence = 0
var wisdom = 0
var armor = 0  # 10 plus your Dexterity Modifier.

var str_mod = 0
var dex_mod = 0
var con_mod = 0
var int_mod = 0
var wis_mod = 0

var max_health = 0
var current_health = 0
var level = 0
var exp_value = 0

var enemy_name = ""


func _ready():
	# Generate my name from a list of various monsters AND apply health and sprites from there
	enemy_name = "Enemy"
	
	level = SaveData.player_level
	
	strength = DiceRoller.stat_roll()
	dexterity = DiceRoller.stat_roll()
	constitution = DiceRoller.stat_roll()
	intelligence = DiceRoller.stat_roll()
	wisdom = DiceRoller.stat_roll()
	
	str_mod = DiceRoller.mod_calculate(strength)
	dex_mod = DiceRoller.mod_calculate(dexterity)
	con_mod = DiceRoller.mod_calculate(constitution)
	int_mod = DiceRoller.mod_calculate(intelligence)
	wis_mod = DiceRoller.mod_calculate(wisdom)
	
	for _i in range(level): # this might be causing it to get stronger unexpectedly. But also its ok!!!!
		level_up()
	
	exp_value = 25 * pow(1 + 0.1, level)
	
	armor = dex_mod + 10
	
	$Weapon.generate_weapon()
	print(self.name + " equipped a " + $Weapon.get_weapon_name())


func level_up():
	for _i in range(2):
		var rand_stat = randi() % 5
		strength += 1 if rand_stat == 0 else 0
		dexterity += 1 if rand_stat == 1 else 0
		constitution += 1 if rand_stat == 2 else 0
		intelligence += 1 if rand_stat == 3 else 0
		wisdom += 1 if rand_stat == 4 else 0
	
	str_mod = DiceRoller.mod_calculate(strength)
	dex_mod = DiceRoller.mod_calculate(dexterity)
	con_mod = DiceRoller.mod_calculate(constitution)
	int_mod = DiceRoller.mod_calculate(intelligence)
	wis_mod = DiceRoller.mod_calculate(wisdom)
	
	max_health += DiceRoller.roll(8) + con_mod
	current_health = max_health


func movement():
	if current_health > 0:
		if target:
			# I would love to implement basic A* here. 
			# If I decide not to, then just find the closest tile to the player and move there.
			# Can only move 4 spaces right? Check which of the 4 is closest lmao
			
			var move_options = []
			move_options.append(Vector2(0, 64))
			move_options.append(Vector2(0, -64))
			move_options.append(Vector2(64, 0))
			move_options.append(Vector2(-64, 0))
			
			var distance_check = 512
			var selected_spot = Vector2(0,0)
			for x in move_options:
				var current_position_distance = (position  + x).distance_to(target.position)
				if current_position_distance < distance_check:
					distance_check = current_position_distance
					selected_spot = x
			
			$RayCast2D.cast_to = selected_spot
			$RayCast2D.force_raycast_update()
			
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider().get_collision_layer_bit(0):
					# ATTACK
					attack($RayCast2D.get_collider())
				
				if $RayCast2D.get_collider().get_collision_layer_bit(1):
					# DONT MOVE SUCKS TO SUCK OMG
					pass
				
				if $RayCast2D.get_collider().get_collision_layer_bit(2):
					# DONT MOVE SUCKS TO SUCK OMG
					pass
				
				if $RayCast2D.get_collider().get_collision_layer_bit(3):
					# DONT MOVE GOOD YOU DID IT
					pass
			else:
				position += selected_spot
		else:
			# If we can't see the player, let's just randomly move
			var rand_dir = randi() % 4
			var move_dir = Vector2()
			
			if rand_dir == 0:
				move_dir = Vector2(0, 64)
			if rand_dir == 1:
				move_dir = Vector2(0, -64)
			if rand_dir == 2:
				move_dir = Vector2(64, 0)
			if rand_dir == 3:
				move_dir = Vector2(-64, 0)
			
			$RayCast2D.cast_to = move_dir
			$RayCast2D.force_raycast_update()
			
			if $RayCast2D.is_colliding():
				if $RayCast2D.get_collider().get_collision_layer_bit(0):
					# ATTACK
					attack($RayCast2D.get_collider())
				
				if $RayCast2D.get_collider().get_collision_layer_bit(1):
					# DONT MOVE SUCKS TO SUCK OMG
					pass
				
				if $RayCast2D.get_collider().get_collision_layer_bit(2):
					# DONT MOVE SUCKS TO SUCK OMG
					pass
				
				if $RayCast2D.get_collider().get_collision_layer_bit(3):
					# DONT MOVE GOOD YOU DID IT
					pass
			else:
				position += move_dir


func damage(amount):
	current_health -= amount
	
	if current_health <= 0:
		# We dead.
		rotation_degrees = 180
		set_collision_layer_bit(1, false)


func attack(target):
	# Attack
	var attack_roll = DiceRoller.roll(20) 
	if attack_roll > target.get_armor():
		var attack_damage = DiceRoller.roll($Weapon.get_weapon_damage())
		
		var bonus_damage = 0
		
		if $Weapon.get_weapon_type() == 0:
			bonus_damage += str_mod
		if $Weapon.get_weapon_type() == 1:
			bonus_damage += dex_mod
		if $Weapon.get_weapon_type() == 2:
			bonus_damage += int_mod
		
		attack_damage += bonus_damage
		
		get_parent().show_dialogue(get_name() + " attacks player for " + str(attack_damage) + ".")
		play_sound(0)
		target.damage(attack_damage)
	else:
		play_sound(1)
		get_parent().show_dialogue(get_name() + " misses.")


func _on_VisionSphere_area_entered(area):
	# JFC I'm going to look at this sober and wonder about my naming.
	if area.get_collision_layer_bit(0): # I see the player!
		target = area


func _on_VisionSphere_area_exited(area):
	if area.get_collision_layer_bit(0): # I can't see the player!
		target = null


func get_health():
	return current_health


func get_exp_value():
	return exp_value


func get_armor():
	return armor


func get_name():
	return enemy_name


func play_sound(index):
	$EffectPlayer.stream = sound_effects[index]
	$EffectPlayer.play()
