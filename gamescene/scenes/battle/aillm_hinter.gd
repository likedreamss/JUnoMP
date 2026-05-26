extends Node
class_name AITestDriver
@export var card_manager: Node
const API_URL = "https://api.deepseek.com/v1/chat/completions"
const API_KEY = "sk-e823173d75d64ac8b2a8693f2e1f67a1"

@onready var http_request: HTTPRequest = HTTPRequest.new()
var is_requesting: bool = false

func _ready() -> void:
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	print_rich("[color=green][AI Test] 调试驱动器就绪！在游戏运行期间，随时按下键盘 [b]H[/b] 键，即可请求一次大模型推荐！[/color]")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_H:
			if is_requesting:
				print_rich("[color=yellow][AI Test] 警告：上一次请求还在计算中，请稍后...[/color]")
				return
			trigger_debug_hint()

func trigger_debug_hint() -> void:
	if not GameGrid.instance:
		print_rich("[color=red][AI Test] 错误：场景中未发现 GameGrid 实例！[/color]")
		return
		
	var battle_manager = get_tree().get_first_node_in_group("battle_manager")
	var target_tile = Vector2i(0, 0)
	if battle_manager:
		target_tile = battle_manager.target_tile
	else:
		print_rich("[color=yellow][AI Test] 警告：未找到 battle_manager 组，终点坐标将默认设为 (0,0) 进行测试。[/color]")

	is_requesting = true
	print_rich("\n[color=cyan]==================== [AI Test] 开始收集盘面数据 ====================[/color]")
	
	var grid_data = GameGrid.instance.get_all_grid_data()
	var serialized_map = _serialize_map(grid_data)
	var player_hand = _collect_player_hand()
	
	var test_payload = {
		"target_tile": {"q": target_tile.x, "r": target_tile.y},
		"player_hand": player_hand,
		"map_grid": serialized_map
	}
	
	print_rich("[AI Test] 发送的局势特征 JSON:\n", JSON.stringify(test_payload, "\t"))
	
	var system_prompt = (
		"你是一款UNO+六边形战棋游戏的终极AI大脑。\n" +
		"地图是大小为12的六边形网格。地形有land, grass, pink, river。\n" +
		"卡牌有：移动牌(LAND_GO_CARD, GRASS_GO_CARD等，可移动到相邻的指定地形)、万能移动牌(UNIVERSAL_GO_CARD)、妨碍牌(LAND_TRICK_CARD等，在指定地形空地放一个障碍物阻挡对手，不能放终点)。\n" +
		"请根据传入的map_grid, player_hand和target_tile，选择最优的一张手牌出牌，并指定推荐格子的坐标。" +
		"必须返回JSON，格式如下，不要包含任何markdown外壳：\n" +
		"{\n" +
		"  \"recommended_card\": \"卡牌card_name\",\n" +
		"  \"target_q\": 0,\n" +
		"  \"target_r\": 0,\n" +
		"  \"reason\": \"你的中文逻辑推导说明\"\n" +
        "}"
	)
	
	var request_data = {
		"model": "deepseek-chat",
		"messages": [
			{"role": "system", "content": system_prompt},
			{"role": "user", "content": JSON.stringify(test_payload)}
		],
		"response_format": {"type": "json_object"},
		"temperature": 0.1
	}
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + API_KEY
	]
	
	print_rich("[color=cyan][AI Test] 数据打包完毕，正在向大模型服务器投递数据...[/color]")
	var err = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(request_data))
	if err != OK:
		print_rich("[color=red][AI Test] 请求发送失败！错误码：", err, "[/color]")
		is_requesting = false

func _serialize_map(grid_data: Dictionary) -> Array:
	var arr = []
	print_rich("[color=cyan][AI Test] 原始 grid_data 大小：", grid_data.size(), "[/color]")
	for pos in grid_data:
		var cell = grid_data[pos]
		arr.append({
			"q": pos.x,
			"r": pos.y,
			"terrain": GameGrid.instance.get_terrain_string(cell["terrain"]),
			"obstacle": GameGrid.instance.get_obstacle_string(cell["obstacle"]),
			"has_player_unit": cell["unit"] != null
		})
	print_rich("[color=cyan][AI Test] 序列化后的 map_grid 大小：", arr.size(), "[/color]")
	return arr

func _collect_player_hand() -> Array:
	var hand = []
	var card_manager = get_node_or_null("/root/Game/UI/CardManager") # 改成你实际的节点路径
	if not card_manager:
		card_manager = get_tree().get_first_node_in_group("card_manager")
	
	if card_manager:
		print_rich("[color=cyan][AI Test] 找到 card_manager 节点[/color]")
		if card_manager.has_method("get_player_cards"):
			print_rich("[color=cyan][AI Test] 调用 get_player_cards(0)[/color]")
			var cards = card_manager.get_player_cards(0)
			print_rich("[color=cyan][AI Test] 原始手牌数据：", cards, "[/color]")
			for card in cards:
				if typeof(card) == TYPE_DICTIONARY:
					hand.append({"card_name": card.get("card_name", "UNKNOWN_CARD")})
				else:
					hand.append({"card_name": card.card_name})
		else:
			print_rich("[color=red][AI Test] card_manager 没有 get_player_cards 方法！[/color]")
	else:
		print_rich("[color=red][AI Test] 未找到 card_manager 节点！[/color]")

	if hand.is_empty():
		hand = [
			{"card_name": "LAND_GO_CARD"},
			{"card_name": "RIVER_TRICK_CARD"}
		]
		print_rich("[color=yellow][AI Test] 场景中未读取到玩家手牌，已使用默认模拟手牌进行评测。[/color]")
	return hand

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	is_requesting = false
	print_rich("[color=cyan]==================== [AI Test] 收到大模型返回反馈 ====================[/color]")
	
	if response_code != 200:
		print_rich("[color=red][AI Test] API请求失败，HTTP 状态码: %d[/color]" % response_code)
		print(body.get_string_from_utf8())
		return
		
	var json = JSON.new()
	var parse_err = json.parse(body.get_string_from_utf8())
	if parse_err != OK:
		print_rich("[color=red][AI Test] 返回的JSON包解析失败[/color]")
		return
		
	var response = json.get_data()
	var content = response["choices"][0]["message"]["content"]
	
	var ai_decision = JSON.parse_string(content)
	if ai_decision:
		print_rich("[color=gold][AI 推荐出牌]: [/color]", ai_decision.get("recommended_card"))
		print_rich("[color=gold][AI 目标坐标]: [/color](", ai_decision.get("target_q"), ", ", ai_decision.get("target_r"), ")")
		print_rich("[color=green][AI 深度战术解析]: [/color]\n", ai_decision.get("reason"))
	else:
		print_rich("[color=red][AI Test] 错误：大模型未按规范的JSON字段返回。[/color]\n", content)
	print_rich("[color=cyan]========================================================================[/color]\n")
