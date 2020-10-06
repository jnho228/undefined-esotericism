extends Node


var step = 0
var can_continue = false

export (Array, AudioStreamSample) var sound_effects

var dialogue = [	"...",
					"...",
					"Guide: ...and that concludes the story on how our world lost the Magic Crystal in the last great war. Ending all magic use for generations now.",
					"Guide: Any questions?",
					"Guide: Great! Let's move on to the Light Crystal.",
					"Guide: This crystal is infused with properties that channel light into our realm. ",
					"Guide: It's unknown where these three crystals came from, but the Light Crystal allows us to see.",
					"Guide: The Magic Crystal allowed our ancestors to utilize magic spells.",
					"Guide: And finally, the Life Crystal is what allows all life to flourish--",
					"Guide: What was that?!", # Spawn enemies now
					"Enemy: We will be taking this!", # enemies run away, shatter, darkness
					"Guide: No! We won't allow you!",
					"...",
					"Enemy: I can't believe you've done this.",
					"Guide: Here, take this! Let's go and try to get that crystal back."]


func _ready():
	pass


func _process(delta):
	# Progress if we hit SPACE
	if Input.is_action_just_pressed("ui_accept") && can_continue:
		play_sound(0)
		# Move Forward
		step += 1
		process_step()
		can_continue = false
		$InputWait.wait_time = .5
		$InputWait.start()


func process_step():
	if step < 9: # 7 is the whats this + screen shake + spawn enemies
		update_dialogue(dialogue[step])
		if step == 4:
			$Guide.position -= Vector2(64,0)
		if step == 5:
			$Player.position -= Vector2(64,0)
		
	if step == 9:
		# show effects here!
		play_sound(1)
		$Enemy1.show()
		$Enemy2.show()
		$Camera2D.start(0.2, 15, 16, 0)
		update_dialogue(dialogue[step])
	
	if step > 9 && step < 15:
		update_dialogue(dialogue[step])
		
		if step == 11:
			$Enemy1.position -= Vector2(64,0)
			$Enemy2.position += Vector2(64,0)
			$LightCrystal.hide()
		
		if step == 12:
			# show an effect here
			play_sound(1)
			$Enemy1.hide()
			$Enemy2.hide()
		
		if step == 14:
			$Player.position -= Vector2(64,0)
			$CanvasModulate.show()
			$Player/Light2D.show()
			play_sound(2)
		
	if step == 15:
		get_tree().change_scene("res://Assets/Scenes/Game/Game.tscn")


func update_dialogue(text):
	$CanvasLayer/DialoguePanel/DialogueText.text = text


func _on_InputWait_timeout():
	can_continue = true


func play_sound(index):
	$EffectPlayer.stream = sound_effects[index]
	$EffectPlayer.play()
