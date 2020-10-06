extends Node


var step = -1
var can_continue = false

export (Array, AudioStreamSample) var sound_effects

var dialogue = [	"Guide: Did you find all the pieces?",
					"Guide: Oh, thank the crystals you found them all.",
					"Guide: I think we can fix this right up!",
					"Guide: There. Good as new!",
					"Guide: Thank you."]


func _process(delta):
	# Progress if we hit SPACE
	if Input.is_action_just_pressed("ui_accept") && can_continue:
		# Move Forward
		play_sound(0)
		step += 1
		process_step()
		can_continue = false
		$InputWait.wait_time = .5
		$InputWait.start()


func process_step():
	if step < 5:
		update_dialogue(dialogue[step])
	else:
		get_tree().change_scene("res://Assets/Scenes/Credits/Credits.tscn")

func update_dialogue(text):
	$CanvasLayer/DialoguePanel/DialogueText.text = text
	
	if step == 1:
		$Player.position += Vector2(64,0)
	
	if step == 2:
		play_sound(1)
		$Guide.position += Vector2(0,64)
	
	if step == 3:
		$LightCrystal.show()


func _on_InputWait_timeout():
	can_continue = true


func play_sound(index):
	$EffectPlayer.stream = sound_effects[index]
	$EffectPlayer.play()
