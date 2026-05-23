extends Node2D
@onready var passbutton: Button = $PASS
@onready var ok: Button = $OK

func _ready() -> void:
	# all cards must be a child of cardmannagere or error!!!!!!!!!!!!!!!!!!!!!!!!!
	add_to_group("PASS")
	add_to_group("OK")



func pass_bool(bool):
	if bool:
		$PASS.disabled = false
		$PASS.visible = true
	else:
		$PASS.disabled = true
		$PASS.visible = false
	

func _on_pass_pressed() -> void:
	get_tree().call_group("battle_manager","discard_turn")


func _on_ok_pressed() -> void:
	OK_bool(0)
	$cardmanager.delate_card()
	await get_tree().create_timer(0.5).timeout
	OK_bool(1)
	
	
func OK_bool(bool):
	if !bool:
		$OK.disabled = true
		$OK.visible = false
	else:
		await get_tree().create_timer(0.5).timeout
		$OK.disabled = false
		$OK.visible = true
	
