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
@onready var panel: Panel = $Panel
@onready var winner_label: Label = $Panel/winner_label
@onready var time_label: Label = $Panel/time_label
@onready var label: Label = $Panel/Label


var game_start_time: float = 0

func _ready():
	# 一开始隐藏选项界面
	$Options.visible = false
	$Help.visible = false
	$Surrender.visible = false
	mask.visible = false
	$Setting.visible = false
	$Help2.visible = false
	$Help3.visible = false
	$Panel.visible = false
	game_start_time = Time.get_ticks_msec() / 1000.0
	add_to_group("option")


#进入选项
func _on_to_options_pressed() -> void:
	$TO_options.visible = false
	$Options.visible = true
	$Help.visible = false
	mask.visible = true
#退出选项
func _on_back_pressed() -> void:
	$TO_options.visible = true
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
	$Help2.visible = false
	$Help3.visible = false


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



func _on_nextpage_1_pressed() -> void:
	$Help.visible = false
	$Help2.visible = true
	$Help3.visible = false


func _on_nextpage_2_pressed() -> void:
	$Help.visible = false
	$Help2.visible = false
	$Help3.visible = true

func _on_lastpage_pressed() -> void:
	$Help.visible = true
	$Help2.visible = false
	$Help3.visible = false

func _on_lastpage_1_pressed() -> void:
	$Help.visible = false
	$Help2.visible = true
	$Help3.visible = false
	
# 显示结算面板
func show_result_panel(winner_id: int):
	mask.visible = false
	$TO_options.visible = false
	$Panel.visible = true
	panel.get_node("winner_label").text = "玩家 %d 胜利！" % winner_id
	var total_time = Time.get_ticks_msec() / 1000.0 - game_start_time
	var total_seconds = int(total_time)
	var minutes = int(total_seconds / 60)
	var seconds = total_seconds % 60
	panel.get_node("time_label").text = "游戏耗时:%02d:%02d" % [minutes, seconds]
	
# 返回菜单
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://meun.tscn")
