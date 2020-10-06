extends Node


export var sound_effect : AudioStreamSample


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NewGameButton_pressed():
	play_sound()
	get_tree().change_scene("res://Assets/Scenes/Sanctuary/OpeningScene.tscn")
	# also should clear SaveData lol
	SaveData.clear_data()


func _on_LoadGameButton_pressed():
	# Will add saving all that persistent data in SaveData into a physical file later today MAYBE
	pass # Replace with function body.


func _on_QuitButton_pressed():
	get_tree().quit()


func play_sound():
	$EffectPlayer.stream = sound_effect
	$EffectPlayer.play()
