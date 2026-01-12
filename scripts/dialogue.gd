extends Control
class_name DialogueBox

@onready var dialogue_label =  $Panel/DialogueText
@onready var next_button = $Panel/Button

var typing_speed = 0.03
var is_typing = false
var full_text = ""

var dialogue = []
var index = 0

func start_dialogue(lines):
	dialogue = lines
	index = 0
	show()
	show_line()
	
func show_line():
	if index >= dialogue.size():
		hide()
		return
	full_text = dialogue[index]["text"]
	dialogue_label.text = ""
	is_typing = true
	next_button.disabled = true
	await type_text(full_text)
	is_typing = false
	next_button.disabled = false

func type_text(text):
	for i in text.length():
		if not is_typing:
			break
		dialogue_label.text += text[i]
		await get_tree().create_timer(typing_speed).timeout
	dialogue_label.text = text
	

func _on_button_button_down() -> void:
	if is_typing:
		is_typing = false
		dialogue_label.text = full_text
		next_button.disabled = false
	else:
		index+= 1
		show_line()
