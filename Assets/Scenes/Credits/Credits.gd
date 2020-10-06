extends Node


var credits_text = [	"\"Undefined Esotericism\"\nby jnho228",
						"Programming: jnho228",
						"Art: Kenney",
						"Music: John Leonard French",
						"Coffee Drank: Too much",
						"Wine Drank: More than coffee",
						"Thank you!"]
var current_text = -1


func _on_Timer_timeout():
	current_text += 1
	
	if current_text > credits_text.size() - 1:
		# Back to title
		get_tree().change_scene("res://Assets/Scenes/Title/Title.tscn")
	else:
		$Label.text = credits_text[current_text]
