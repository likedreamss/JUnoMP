extends CanvasLayer

@onready var panel = $Tippanel
@onready var label = $Tippanel/TipLabel
@onready var timer = $Timer

func _ready():

	Toast.toast_ui = self

	panel.visible = false

func show_toast(text):

	label.text = str(text)

	panel.visible = true

	timer.start(2)

func _on_timer_timeout():

	panel.visible = false
