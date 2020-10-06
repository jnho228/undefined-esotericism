extends Node

# Holds 2 values, type and attack die. Ex) "Dagger, 4"
var weapon_dictionary = {	"Club" : 4,				# Melee Weapons
							"Dagger" : 4,
							"Greatclub" : 8,
							"Handaxe" : 6,
							"Javelin" : 6,
							"Light Hammer" : 4,
							"Mace" : 6,
							"Quaterstaff" : 6,
							"Sickle" : 4,
							"Spear" : 6,
							"Battleaxe" : 8,
							"Flail" : 8,
							"Glaive" : 10,
							"Greataxe" : 12,
							"Greatsword" : 12, # 2d6.... figure this out later
							"Halberd" : 10,
							"Lance" : 12,
							"Longsword" : 8,
							"Maul" : 12, # 2d6
							"Morningstar" : 8,
							"Pike" : 10,
							"Rapier" : 8,
							"Scimitar" : 6,
							"Shortsword" : 6,
							"Trident" : 6,
							"War Pick" : 8,
							"Warhammer" : 8,
							"Whip" : 4 } #,
#							"Light Crossbow" : 8,	# Ranged Weapons
#							"Dart" : 4,
#							"Shortbow" : 6,
#							"Sling" : 4,
#							"Blowgun" : 1,
#							"Hand Crossbow" : 6,
#							"Heavy Crossbow" : 10,
#							"Longbow" : 8}
var adjective_prefix	# Comes before name, like "Great..."
var adjective_suffix	# Comes after name, like "...the Destoryer"
var weapon_type			# Infer from weapon_dictionary
						# 0 = Melee / 1 = Ranged / 2 = Magic
var weapon_name
var weapon_damage


func generate_weapon():
	var selected_weapon = randi() % weapon_dictionary.size()
	
	# do fancy shit with prefixes and suffixs later
	weapon_name = weapon_dictionary.keys()[selected_weapon]
	
	weapon_damage = weapon_dictionary.values()[selected_weapon]
	
	if selected_weapon >= 0 && selected_weapon <= 27:
		weapon_type = 0
	elif selected_weapon >= 28 && selected_weapon <= 35:
		weapon_type = 1
	else:
		weapon_type = 2


func get_weapon_name():
	return weapon_name


func get_weapon_damage():
	return weapon_damage


func get_weapon_type():
	return weapon_type


func get_weapon_info():
	var x = [weapon_name, weapon_damage, weapon_type]
	return x


func set_weapon_info(weapon_info):
	weapon_name = weapon_info[0]
	weapon_damage = weapon_info[1]
	weapon_type = weapon_info[2]
