extends Control

@onready var button_sound = $ButtonSound


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	# 格式：res://场景路径/场景文件名.tscn
	# 注意：路径必须以 res:// 开头，后缀是 .tscn
	get_tree().change_scene_to_file("res://GameMain/main_game.tscn")



func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit()
	

func connect_buttons(node):
	for child in node.get_children():
		if child is Button:
			child.pressed.connect(play_button_sound)
		connect_buttons(child)
	

func play_button_sound():
	button_sound.play()

func _ready() -> void:
	connect_buttons(self)
	
