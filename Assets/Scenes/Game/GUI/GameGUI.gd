extends Control


var dialogue_text = []
export (Array, AudioStreamSample) var sound_effects


func _ready():
	if SaveData.dialogue_text:
		dialogue_text = SaveData.dialogue_text
		
		var display_text = ""
		
		for i in dialogue_text:
			display_text += "\n" + i
		
		$DialoguePanel/DialogueLabel.text = display_text


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
		$PausePanel.show()


#func set_health_bar(current_amount, max_amount):
#	$HPIcon/HealthBar.max_value = max_amount
#	$HPIcon/HealthBar.value = current_amount


#func set_exp_bar(current_amount, max_amount):
#	$EXPIcon/ExperienceBar.max_value = max_amount
#	$EXPIcon/ExperienceBar.value = current_amount


func _on_Player_health_changed(current_amount, max_amount): # Let's add smooth transitions later :)
	$HPIcon/HealthBar.max_value = max_amount
	$HPIcon/HealthBar.value = current_amount


func _on_Player_exp_changed(current_amount, max_amount):
	$EXPIcon/ExperienceBar.max_value = max_amount
	$EXPIcon/ExperienceBar.value = current_amount


func _on_Player_weapon_changed(weapon_name):
	$HPIcon/WeaponLabel.text = weapon_name


func show_level_up_panel():
	$LevelUpPanel.show()


func _on_ConfirmButton_pressed():
	print("Pretending like I'm saving the new data values cool")
	$LevelUpPanel.hide()
	get_tree().paused = false


func show_dialogue(text):
	dialogue_text.append(text)
	
	if dialogue_text.size() > 10: # If we have more than 10 items
		dialogue_text.remove(0)
	
	var display_text = ""
	
	for i in dialogue_text:
		display_text += "\n" + i
	
	$DialoguePanel/DialogueLabel.text = display_text
	
	SaveData.dialogue_text = dialogue_text


func _on_ReturnToGameButton_pressed():
	$PausePanel.hide()
	get_tree().paused = false
	play_sound(0)


func _on_ReturnToTitleButton_pressed():
	get_tree().paused = false
	play_sound(0)
	get_tree().change_scene("res://Assets/Scenes/Title/Title.tscn")


func update_crystal_text():
	$CrystalIcon/CrystalCountLabel.text = str(SaveData.crystals_collected) + " / 8"


func show_game_over():
	get_tree().paused = true
	$GameOverPanel.show()


func play_sound(index):
	$EffectPlayer.stream = sound_effects[index]
	$EffectPlayer.play()
