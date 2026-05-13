extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 获取屏幕大小
	var screen_size = get_viewport_rect().size

	# 设置棋盘在中间
	var board_node = $Battle
	# 假设棋盘原点在左上角，可以将它中心对齐屏幕中心
	board_node.position = screen_size / 2 - board_node.get_size() / 2

	# 设置卡牌在下方居中
	var card_node = $CARDMAIN
	# 将卡牌中心水平对齐屏幕中心，垂直放在底部附近
	card_node.position.x = screen_size.x / 2 - card_node.get_size().x / 2
	card_node.position.y = screen_size.y - card_node.get_size().y - 20 # 20像素距离底部
