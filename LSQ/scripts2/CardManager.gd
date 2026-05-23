extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2



var card_slot_found
var card_being_dragged
var screen_size
var is_hovering_on_card
var player_hand_reference
var card_is_in_slot
var slot_has_card

	# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../ImputManager".connect("left_mouse_button_released",on_left_click_released)
	add_to_group("cardmanager")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_local_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0,screen_size.x),
			clamp(mouse_pos.y, 0,screen_size.y))
	
#func _input(event):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			#var card = raycast_check_for_card()
			#if card:
				#start_drag(card)
		#else:
			#if card_being_dragged :
				#finish_drag()	


func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(0.95,0.95)


func finish_drag():
	card_being_dragged.scale = Vector2(1.1,1.1)
	card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		
		card_is_in_slot = card_being_dragged
		$"..".pass_bool(0)
		$"..".CANCEL_bool(1)
		slot_has_card = card_slot_found
		if card_being_dragged.card == 1:
			$"../PH1online".remove_card_from_hand(card_being_dragged)
		elif card_being_dragged.card == 2:
			$"../PH2online".remove_card_from_hand(card_being_dragged)
		else:
			player_hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
		
		#添加音效
		var player = AudioStreamPlayer.new()
		player.stream = preload("res://QYK/Assest1/出牌(outCard).mp3")
		player.bus = "SFX"
		add_child(player)
		player.play()
		# 播放完自动销毁节点
		player.finished.connect(player.queue_free)
		
	else:
		match card_being_dragged.card:
			0:
				player_hand_reference.add_card_to_hand(card_being_dragged)
			1:
				$"../PH1online".add_card_to_hand(card_being_dragged)
			2:
				$"../PH2online".add_card_to_hand(card_being_dragged)
		

		
	card_being_dragged = null

func cancel_card():
	if slot_has_card:
		var card = card_is_in_slot 
		match card.card:
			0:
				player_hand_reference.add_card_to_hand1(card)
			1:
				$"../PH1online".add_card_to_hand1(card)
			2:
				$"../PH2online".add_card_to_hand1(card)
		card.get_node("Area2D/CollisionShape2D").disabled = false
		card_slot_found.card_in_slot = false

	

#删除卡牌代码
func delate_card():
	if slot_has_card == null:
		pass
	elif slot_has_card.card_in_slot:
		$"..".pass_bool(1)
		var card_drawn_name_return = card_is_in_slot.get_node("Code").text
		var card_drawn_value_return = [card_is_in_slot.get_node("Color").text,
		card_is_in_slot.get_node("Function").text,
		card_is_in_slot.get_node("Name").text,
		card_is_in_slot.get_node("Code").text]
		
		get_tree().call_group("battle_manager","play_card_from_ui",card_drawn_value_return)
		
		$"../Deck".delate_card_return(card_drawn_name_return,card_drawn_value_return)
		
	else:
		pass

func delate_card_animate():
	if slot_has_card.card_in_slot:
		var new_position = Vector2(210,1220)
		player_hand_reference.animate_card_to_position(card_is_in_slot,new_position,0.3)
		await get_tree().create_timer(0.3).timeout
		card_is_in_slot.queue_free()
		slot_has_card.card_in_slot = false


func discard_card(discard_nume):#弃牌函数
	if slot_has_card == null:
		return discard_nume
	elif slot_has_card.card_in_slot:
		var card_drawn_name_return = card_is_in_slot.get_node("Code").text
		var card_drawn_value_return = [card_is_in_slot.get_node("Color").text,
		card_is_in_slot.get_node("Function").text,
		card_is_in_slot.get_node("Name").text,
		card_is_in_slot.get_node("Code").text]
		
		$"../Deck".delate_card_return(card_drawn_name_return,card_drawn_value_return)
		delate_card_animate()
		discard_nume -= 1
		return discard_nume 
	else:
		return discard_nume
	
	



func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_left_click_released():
	if card_being_dragged :
		finish_drag()	


func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card,true)


func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card,false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered,true)
		else:
			is_hovering_on_card = false





func highlight_card(card,hovered):
	if hovered:
		card.scale = Vector2(1.1,1.1)
		card.z_index = 2
	else:
		card.scale = Vector2(1,1)
		card.z_index = 1

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0 :
		return result[0].collider.get_parent()
	return null

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0 :
		return get_card_with_highest_z_index(result) 
	return null



func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1,cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
	
