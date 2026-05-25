extends Control

@export var bgm: AudioStream

@onready var button_sound = $ButtonSound


func _ready():

	connect_buttons(self)


func connect_buttons(node):

	for child in node.get_children():

		if child is Button:

			child.pressed.connect(play_button_sound)

		connect_buttons(child)

func play_button_sound():

	button_sound.play()
