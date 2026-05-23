extends Node2D


const CARD_SCENE_PATH ="res://LSQ/scene2/card2.tscn"

var card_database_reference


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_database_reference = preload("res://LSQ/scripts2/CardDatabase.gd")
	
	add_to_group("deck2")#用来解决节点不在一起的情况
	
	
	
	
	
#这里要大改(发牌数在inpumanner里最后)
func draw_card(card_count):
	#.dissabled = true
	#$Area2D/CollisionShape2D.visible = false第五期十一分钟
	

	var card_scene = preload(CARD_SCENE_PATH)
	for i in range(card_count):
		#抽牌数
		var card_drawn_name = card_database_reference.CARDS.keys()[0]
		#var card_drawn_name = player_deck[0]
		#player_deck.erase(card_drawn_name)
		var new_card = card_scene.instantiate()
		var card_drawn_color = str(card_database_reference.CARDS[card_drawn_name][0])
		var card_drawn_function = str(card_database_reference.CARDS[card_drawn_name][1])
		var card_image_patha = str("res://LSQ/sucai/"+ card_drawn_color +"_"+card_drawn_function + "_CARD.png")
		Toast.show(card_drawn_color)
		Toast.show(card_drawn_function)
		new_card.get_node("CardImage").texture = load(card_image_patha)
		new_card.get_node("Color").text = str(card_database_reference.CARDS[card_drawn_name][0])
		new_card.get_node("Function").text =str(card_database_reference.CARDS[card_drawn_name][1])
		new_card.get_node("Name").text = str(card_database_reference.CARDS[card_drawn_name][2])
		new_card.get_node("Code").text = str(card_database_reference.CARDS[card_drawn_name][3])
		card_database_reference.CARDS.erase(card_drawn_name)
		new_card.visible(1)
		$"../cardmanager".add_child(new_card)
		#remove_child!!!!!
		new_card.name = "Card"
		new_card.group_change()
		$"../PH2online".add_card_to_hand(new_card)
	
