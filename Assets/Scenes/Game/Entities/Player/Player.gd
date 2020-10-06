extends Area2D


export (Array, AudioStreamSample) var sound_effects
export (Array, Texture) var vision_radius

signal turn_completed
signal collected_crystal
signal dead
signal health_changed(current_amount, max_amount)
signal exp_changed(current_amount, max_amount)
signal weapon_changed(weapon_name)

var can_move = false
var move_direction = Vector2(0,0)

var strength = 0
var dexterity = 0
var constitution = 0
var intelligence = 0
var wisdom = 0
var armor = 0

var str_mod = 0
var dex_mod = 0
var con_mod = 0
var int_mod = 0
var wis_mod = 0

var max_health = 0
var current_health = 0

var level = 1
var crystals_collected

var exp_to_level = 100
var current_exp = 0


func _ready():
	level = SaveData.player_level
	crystals_collected = SaveData.crystals_collected
	
	$Light2D.texture = vision_radius[crystals_collected]
	
	strength = SaveData.player_str
	dexterity = SaveData.player_dex
	constitution = SaveData.player_con
	intelligence = SaveData.player_int
	wisdom = SaveData.player_wis
	
	str_mod = DiceRoller.mod_calculate(strength)
	dex_mod = DiceRoller.mod_calculate(dexterity)
	con_mod = DiceRoller.mod_calculate(constitution)
	int_mod = DiceRoller.mod_calculate(intelligence)
	wis_mod = DiceRoller.mod_calculate(wisdom)
	
	armor = dex_mod + 10
	
	max_health = SaveData.player_max_health
	current_health = SaveData.player_current_health
	
	exp_to_level = SaveData.player_exp_to_level
	current_exp = SaveData.player_current_exp
	
	emit_signal("health_changed", current_health, max_health)
	emit_signal("exp_changed", current_exp, exp_to_level)
	
	if !SaveData.player_weapon:
		$Weapon.generate_weapon()
	else:
		$Weapon.set_weapon_info(SaveData.player_weapon)
	emit_signal("weapon_changed", $Weapon.get_weapon_name())
	print(self.name + " equipped a " + $Weapon.get_weapon_name())


func _process(_delta):	
	if can_move:
		if Input.is_action_just_pressed("ui_up"):
			move_direction = Vector2(0,-64)
			movement()
		if Input.is_action_just_pressed("ui_down"):
			move_direction = Vector2(0,64)
			movement()
		if Input.is_action_just_pressed("ui_left"):
			move_direction = Vector2(-64,0)
			movement()
		if Input.is_action_just_pressed("ui_right"):
			move_direction = Vector2(64,0)
			movement()


func movement():	
	#Send out a RayCast and see if we can move!
	$RayCast2D.cast_to = move_direction
	$RayCast2D.force_raycast_update()
	
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider().get_collision_layer_bit(1):
			# ATTACK
			attack($RayCast2D.get_collider())
		
		if $RayCast2D.get_collider().get_collision_layer_bit(2):
			# COLLECT
			SaveData.player_weapon = $Weapon.get_weapon_info()
			emit_signal("collected_crystal")
			position += move_direction
			
		if $RayCast2D.get_collider().get_collision_layer_bit(3):
			# DONT MOVE GOOD YOU DID IT
			pass
	
	else:
		position += move_direction
		# Passive healing I guess
		current_health += 1 + (floor(con_mod/2) if con_mod > 0 else 0) # might be too strong
		
		if current_health > max_health:
			current_health = max_health
		
		emit_signal("health_changed", current_health, max_health)
	
	# End our turn
	can_move = false
	emit_signal("turn_completed")


func damage(amount):
	current_health -= amount
	
	if current_health <= 0:
		current_health = 0
	
	$Camera2D.start(0.2, 15, 16, 0)
	emit_signal("health_changed", current_health, max_health)
	
	if current_health <= 0:
		# I am dead. Trigger game over.
		emit_signal("dead")


func attack(target):
	# ATTACK
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
		
		$Camera2D.start(0.2, 15, 16, 0)
		play_sound(0)
		
		var killed_target = true if target.get_health() - attack_damage <= 0 else false
		
		get_parent().show_dialogue("Player attacks " + target.get_name() + " for " + str(attack_damage) + ".")
		target.damage(attack_damage)
		
		if killed_target:
			current_exp += target.get_exp_value()
			
			emit_signal("exp_changed", current_exp, exp_to_level)
			
			if current_exp >= exp_to_level:
				level_up()
	else:
		play_sound(1)
		get_parent().show_dialogue("Player misses.")


func get_armor():
	return armor


func level_up(): 
	# Calculate extra exp
	var leftover_exp = 0
	if current_exp >= exp_to_level:
		leftover_exp = current_exp - exp_to_level	
	
	level += 1
	exp_to_level = 100 * pow(1 + 0.2, level)
	current_exp = leftover_exp
	
	emit_signal("exp_changed", current_exp, exp_to_level)
	
	# calculate stat increases here!
	for _i in range(2):
		var rand_stat = randi() % 5
		strength += 1 if rand_stat == 0 else 0
		dexterity += 1 if rand_stat == 1 else 0
		constitution += 1 if rand_stat == 2 else 0
		intelligence += 1 if rand_stat == 3 else 0
		wisdom += 1 if rand_stat == 4 else 0
	
	max_health = DiceRoller.roll(8) + con_mod
	current_exp = max_health
	
	emit_signal("health_changed", current_health, max_health)
	
	# Recalculate mods
	str_mod = DiceRoller.mod_calculate(strength)
	dex_mod = DiceRoller.mod_calculate(dexterity)
	con_mod = DiceRoller.mod_calculate(constitution)
	int_mod = DiceRoller.mod_calculate(intelligence)
	wis_mod = DiceRoller.mod_calculate(wisdom)
	
	armor = dex_mod + 10
	
	play_sound(2)
	get_parent().show_dialogue("You are now level " + str(level) + ".")
	
	# Check again if we can level up or not
	if current_exp >= exp_to_level:
		level_up()


func play_sound(index):
	$EffectPlayer.stream = sound_effects[index]
	$EffectPlayer.play()
