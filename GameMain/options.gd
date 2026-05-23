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
@onready var surrenderlabel: Label = $Surrender/Surrenderlabel
@onready var surback: Button = $Surrender/Surback
@onready var mask: ColorRect = $Mask

func _ready():
	# 一开始隐藏选项界面
	$Options.visible = false
	$Help.visible = false
	$Surrender.visible = false
	mask.visible = false
	$Setting.visible = false

#进入选项
func _on_to_options_pressed() -> void:
	$Options.visible = true
	$Help.visible = false
	mask.visible = true
#退出选项
func _on_back_pressed() -> void:
	$Options.visible = false
	$Help.visible = false
	mask.visible = false
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
	$Setting.visible = true
	$Options.visible = false
	$Help.visible = false

func _on_setback_pressed() -> void:
	$Setting.visible = false
	$Options.visible = true
	
func _on_surback_pressed() -> void:
	get_tree().change_scene_to_file("res://meun.tscn")

func _on_leave_button_pressed() -> void:
		# 获取当前正在回合的玩家
	var battle = get_tree().get_first_node_in_group("battle_manager")
	if not battle:
		return
	
	var current_player = battle.get_current_player()
	# 设置投降文字：显示当前玩家投降
	surrenderlabel.text = "玩家 " + str(current_player.player_id) + " 已投降！🏳"
	
	# 显示投降面板
	$Surrender.visible = true
	$Options.visible = false
	
	# 执行投降逻辑：游戏结束，该玩家判负
	battle.game_finished = true
	battle.set_process_input(false)
	# 调用胜利面板，显示其他玩家胜利（剩下第一个存活玩家胜利）
	battle.show_result_panel((current_player.player_id + 1) % 3)
