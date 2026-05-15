extends Node2D
#初始手牌
const HAND_COUNT = 5
const CARD_SCENE_PATH ="res://LSQ/scene2/card.tscn"
var CARD_WIDTH = 150

#卡牌间隔
var card_database_reference_a



var HAND_Y_POSITION = 1220
#手牌位置高度
var player_hand = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player_hand")
	center_screen_x = get_viewport().size.x / 2
	card_database_reference_a = preload("res://LSQ/scripts2/CardDatabase.gd")
	##发牌
	var card_scene = preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT+2):
		var card_drawn_start = card_database_reference_a.CARDS.keys()[0]
		#var card_drawn_start_color = str(card_database_reference_a.CARDS[card_drawn_start][0])
		#var card_drawn_start_function = str(card_database_reference_a.CARDS[card_drawn_start][1])
		var new_card = card_scene.instantiate()
		#var card_image_path = str("res://LSQ/sucai/"+ card_drawn_start_color + "_"+card_drawn_start_function+"_CARD.png")
	
		new_card.get_node("Color").text = str(card_database_reference_a.CARDS[card_drawn_start][0])
		new_card.get_node("Function").text =str(card_database_reference_a.CARDS[card_drawn_start][1])
		new_card.get_node("Name").text = str(card_database_reference_a.CARDS[card_drawn_start][2])
		new_card.get_node("Code").text = str(card_database_reference_a.CARDS[card_drawn_start][3])
		var card_image_path = str("res://LSQ/sucai/"+ new_card.get_node("Color").text + "_"+new_card.get_node("Function").text+"_CARD.png")
		new_card.get_node("CardImage").texture = load(card_image_path)
		card_database_reference_a.CARDS.erase(card_drawn_start)
		$"../cardmanager".add_child(new_card)
		new_card.name = "Card"
		new_card.group_change()
		new_card.visible(1)
		add_card_to_hand(new_card)



func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0,card)
		update_hand_positions()
	else:
		animate_card_to_position(card, card.starting_position,0.2)
	
func update_hand_positions():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i),HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card,new_position,1)


func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offest = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offest


func animate_card_to_position(card,new_position,speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	return tween

#！！！！！！！！1 is the 入场动画速度

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()

func player_card_change(player_id):
	match player_id:
		0:
			CARD_WIDTH = 150

			HAND_Y_POSITION = 1220
			center_screen_x = get_viewport().size.x / 2
			for i in range(player_hand.size()):
				var new_position = Vector2(calculate_card_position(i),HAND_Y_POSITION)
				var card = player_hand[i]
				card.starting_position = new_position
				animate_card_to_position(card,new_position,0.5)
		1:
			CARD_WIDTH = 50

			HAND_Y_POSITION = get_viewport().size.y / 10
			center_screen_x = get_viewport().size.x * 2 / 10
			for i in range(player_hand.size()):
				var new_position = Vector2(calculate_card_position(i),HAND_Y_POSITION)
				var card = player_hand[i]
				card.starting_position = new_position
				animate_card_to_position(card,new_position,0.5)
		2:
			CARD_WIDTH = 50

			HAND_Y_POSITION = get_viewport().size.y / 10
			center_screen_x = get_viewport().size.x *8/10
			for i in range(player_hand.size()):
				var new_position = Vector2(calculate_card_position(i),HAND_Y_POSITION)
				var card = player_hand[i]
				card.starting_position = new_position
				animate_card_to_position(card,new_position,0.5)





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
