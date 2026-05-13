extends CanvasLayer

@onready var help_button: Button = $HelpButton
@onready var helpbutton_back: Button = $Helpbutton_back
@onready var setting_button: Button = $SettingButton
@onready var leave_button: Button = $leaveButton
@onready var back: Button = $back
@onready var to_options: Button = $TO_options
@onready var options: Panel = $Options
@onready var optionstitle: Label = $Optionstitle
@onready var help: Label = $Help


func _ready():
	# 一开始隐藏选项界面
	$Options.visible = false
	$Help.visible = false

#进入选项
func _on_to_options_pressed() -> void:
	$Options.visible = true
	$Help.visible = false

#退出选项
func _on_back_pressed() -> void:
	$Options.visible = false
	$Help.visible = false
	
# 跳转到帮助场景（自己改路径）
func _on_help_button_pressed() -> void:
	$Options.visible = false
	$Help.visible = true
	
#退出帮助场景
func _on_helpbutton_back_pressed() -> void:
	$Options.visible = true
	$Help.visible = false

#跳转到设置界面
func _on_setting_button_pressed() -> void:
	pass # Replace with function body.
	
