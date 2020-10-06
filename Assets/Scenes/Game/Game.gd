extends Node


export (PackedScene) var player_object
export (PackedScene) var enemy_object
export (PackedScene) var crystal_object

export (Array, PackedScene) var outer_wall_tiles
export (Array, PackedScene) var ground_tiles
export (Array, PackedScene) var obstacle_tiles

export (Array, AudioStreamSample) var sound_effects
export (Array, AudioStreamSample) var music

#var player
var enemies = []
var crystal

var crystal_colleted : bool = false
var player_dead : bool = false


func _ready():
	generate_world()
	$AudioStreamPlayer.stream = music[0]
	$AudioStreamPlayer.play()


func generate_world():
	# Decide the level size
	var level_size = Vector2(	(SaveData.crystals_collected * 2) + randi() % 10 + 10, 
								(SaveData.crystals_collected * 2) + randi () % 10 + 10)

	# Create an array to check if tiles are used or not.
	var level_tile_check = []
	for x in range(level_size.x):
		level_tile_check.append([])
		for _y in range(level_size.y):
			level_tile_check[x].append(0)

	# Put the level border
	for x in range(level_size.x):
		for y in range(level_size.y):
			if x == 0 || x == level_size.x-1 || y == 0 || y == level_size.y-1:
				# Spawn a level border
				var new_outer_wall = outer_wall_tiles[randi() % outer_wall_tiles.size()].instance()
				call_deferred("add_child", new_outer_wall)
				new_outer_wall.position = Vector2(x * 64, y * 64)
				level_tile_check[x][y] = 1

	# Spawn ground decorations
	for x in range(level_size.x):
		for y in range(level_size.y):
			if x > 0 && x < level_size.x - 1 && y > 0 && y < level_size.y - 1:
				var spawn_chance = rand_range(0, 10)
				if spawn_chance > 5:
					var new_ground = ground_tiles[randi() % ground_tiles.size()].instance()
					call_deferred("add_child", new_ground)
					new_ground.position = Vector2(x * 64, y * 64)

	# Spawn Obstacles - 1st inside cycle is kept open
	for x in range(level_size.x):
		for y in range(level_size.y):
			if x > 1 && x < level_size.x - 2 && y > 1 && y < level_size.y - 2:
				var spawn_chance = rand_range(0, 10)
				if spawn_chance > 8.5:
					var new_obstacle = obstacle_tiles[randi() % obstacle_tiles.size()].instance()
					call_deferred("add_child", new_obstacle)
					new_obstacle.position = Vector2(x * 64, y * 64)
					level_tile_check[x][y] = 1

	# Spawn Enemies
	var level_enemies = SaveData.player_level + (randi() % 3 + 2)
	for _i in range(level_enemies):
		enemies.append(enemy_object.instance())
		call_deferred("add_child", enemies[_i])

		var spawn_x = randi() % int(level_size.x)
		var spawn_y = randi() % int(level_size.y)
		while(level_tile_check[spawn_x][spawn_y] == 1):
			spawn_x = randi() % int(level_size.x)
			spawn_y = randi() % int(level_size.y)

		enemies[_i].position = Vector2(spawn_x * 64, spawn_y * 64)
		level_tile_check[spawn_x][spawn_y] = 1

	# Place the Player
#	player = player_object.instance()
#	call_deferred("add_child", player)

	var spawn_x = randi() % int(level_size.x)
	var spawn_y = randi() % int(level_size.y)
	while(level_tile_check[spawn_x][spawn_y] == 1):
		spawn_x = randi() % int(level_size.x)
		spawn_y = randi() % int(level_size.y)

	$Player.position = Vector2(spawn_x * 64, spawn_y * 64)
	level_tile_check[spawn_x][spawn_y] = 1
	
#	player.connect("collected_crystal", self, "on_Player_collected_crystal")

	# Spawn the crystal
	crystal = crystal_object.instance()
	call_deferred("add_child", crystal)

	spawn_x = randi() % int(level_size.x)
	spawn_y = randi() % int(level_size.y)
	while(level_tile_check[spawn_x][spawn_y] == 1):
		spawn_x = randi() % int(level_size.x)
		spawn_y = randi() % int(level_size.y)
	
	# Probably should add an extra check in here JUST in case it is surrounded by all four sides.
	# In a real reality I would ensure that a rough, I guess, A* or maze algorithm or something idfk would be able to see the player upon spawning. 

	crystal.position = Vector2(spawn_x * 64, spawn_y * 64)
	level_tile_check[spawn_x][spawn_y] = 1
	
	$CanvasLayer/GameGUI.update_crystal_text()
	
	game_loop()


func game_loop():
	# Player's Turn
	#print("Player's Turn")
	$Player.can_move = true
	yield($Player, "turn_completed")
	yield(get_tree().create_timer(0.01), "timeout")

	# Enemies' Turn
	#print("Enemy's Turn")
	for x in enemies:
		x.movement()
		yield(get_tree().create_timer(0.01), "timeout") # if you revisit this, make the timer only if the player can see them.
	
	# Have we collected a crystal? / load new level
	if crystal_colleted:
		SaveData.crystals_collected += 1
		
		print(SaveData.crystals_collected)
		
		if SaveData.crystals_collected >= 8: #IDK why 8 lol
			get_tree().change_scene("res://Assets/Scenes/Sanctuary/EndingScene.tscn")
		else:
			# Rebuld the entire world. :)
			SaveData.player_level = $Player.level
			
			SaveData.player_str = $Player.strength
			SaveData.player_dex = $Player.dexterity
			SaveData.player_con = $Player.constitution
			SaveData.player_int = $Player.intelligence
			SaveData.player_wis = $Player.wisdom
			
			SaveData.player_max_health = $Player.max_health
			SaveData.player_current_health = $Player.current_health
			SaveData.player_exp_to_level = $Player.exp_to_level
			SaveData.player_current_exp = $Player.current_exp
			
			get_tree().change_scene("res://Assets/Scenes/Game/Game.tscn")
	
	# Have we died? lmao
	if player_dead:
		# Absolutely should be different but oh fucking well
		show_dialogue("Player has been slain.")
		#get_tree().change_scene("res://Assets/Scenes/Title/Title.tscn")
		$CanvasLayer/GameGUI.show_game_over()

	# Check if we should continue
	game_loop()


func show_dialogue(text):
	$CanvasLayer/GameGUI.show_dialogue(text)


func _on_Player_collected_crystal():
	play_sound(0)
	crystal_colleted = true


func _on_Player_dead():
	player_dead = true
	$AudioStreamPlayer.stream = music[1]
	$AudioStreamPlayer.play()


func play_sound(index):
	$EffectPlayer.stream = sound_effects[index]
	$EffectPlayer.play()
