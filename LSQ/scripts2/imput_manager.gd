extends Node2D


signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_OK = 4
const COLLISION_MASK_PASS = 8




var card_manager_reference
var deck_reference



func _ready() -> void:
	card_manager_reference = $"../cardmanager"
	deck_reference = $"../Deck"


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")
			
func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0 :
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			#卡牌点击后
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_manager_reference.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_OK:
			#牌堆点击后
			$"../cardmanager".delate_card()
			
		elif result_collision_mask == COLLISION_MASK_PASS:
			
			get_tree().call_group("battle_manager","next_turn")
			
			
			pass
