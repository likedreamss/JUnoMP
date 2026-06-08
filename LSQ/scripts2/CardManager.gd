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
	
	if not has_node("AI_HTTPRequest"):
		ai_http_request = HTTPRequest.new()
		ai_http_request.name = "AI_HTTPRequest"
		add_child(ai_http_request)
		# 💡 注意：这里我们不在 ready 里直接 bind 传参，防止每次按 F 导致连接冲突
		
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_local_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0,screen_size.x),
			clamp(mouse_pos.y, 0,screen_size.y))
		
	# 使用 is_action_just_pressed 或严格的单帧 key 过滤，确保切换回合后按下 F 读取的是全新对局数据
	if Input.is_key_pressed(KEY_F):
		if not Engine.get_main_loop().has_meta("ai_hint_cooldown"):
			Engine.get_main_loop().set_meta("ai_hint_cooldown", true)
			get_ai_suggestion()
	else:
		if Engine.get_main_loop().has_meta("ai_hint_cooldown"):
			Engine.get_main_loop().remove_meta("ai_hint_cooldown")
			
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
	if card_slot_found.card_in_slot:
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
	
	
	
#真实 AI (DeepSeek) 局势战略进阶v
const DEEP_SEEK_API_KEY = "sk-bf668ed71bb9446e858e41e150238db8" # 🔑 填入你的 DeepSeek API Key
const DEEP_SEEK_URL = "https://api.deepseek.com/v1/chat/completions"

var ai_http_request: HTTPRequest = null

## 核心接口：结合战棋对局态势与多玩家手牌集群向 DeepSeek 发起出牌/弃牌智能咨询
func get_ai_suggestion() -> void:
	var battle_manager = get_tree().get_first_node_in_group("battle_manager")
	if not battle_manager:
		print("[AI 错误] 场景树中未侦测到处于 'battle_manager' 分组的对局核心节点。")
		return

	# 1. 【手牌容器动态映射】：精准同步当前回合玩家的真实卡池，拒绝交叉污染
	var current_hand_cards = []
	var player_idx = battle_manager.current_player_index # 0=P1, 1=P2, 2=P3
	
	match player_idx:
		0:
			if player_hand_reference: 
				current_hand_cards = player_hand_reference.player_hand
		1:
			var ph1 = get_node_or_null("../PH1online")
			if ph1: current_hand_cards = ph1.player_hand
		2:
			var ph2 = get_node_or_null("../PH2online")
			if ph2: current_hand_cards = ph2.player_hand

	# 保底分组检索方案
	if current_hand_cards.size() == 0:
		var actual_id = (battle_manager.current_player_index + battle_manager.player_id_count) % battle_manager.players.size()
		var target_group = "player_hand" + str(actual_id)
		var hand_nodes = get_tree().get_nodes_in_group(target_group)
		if hand_nodes.size() > 0 and "player_hand" in hand_nodes[0]:
			current_hand_cards = hand_nodes[0].player_hand

	if current_hand_cards.size() == 0:
		print("[AI 提示] 正在同步当前回合玩家的手牌数据，请稍后重试...")
		return


	
	var is_discard_phase: bool = battle_manager.is_in_discard_phase

	# 打印明文核心侦测日志（修复%b报错）
	Toast.show("[AI 精准状态侦测] 活跃玩家: 玩家 %d | 当前手牌数: %d | 判定为: 【%s】" % [
		player_idx + 1,
		current_hand_cards.size(),
		"🗑️ 弃牌阶段 (DISCARD)" if is_discard_phase else "⚔️ 出牌/移动阶段 (PLAY)"
	])

	# 3. 安全拦截：如果是出牌阶段，但当前棋子处于中了【束手待毙】的封印状态，直接报 PASS
	if not is_discard_phase:
		var current_unit = battle_manager.get_current_player()
		if current_unit and current_unit.player_id in battle_manager.skip_flags["play"]:
			print("[AI 提示] 玩家 %d 当前中了【束手待毙】状态，本回合已被强行禁言，请直接点击 PASS 结束回合。" % (player_idx + 1))
			return

	# 4. 局势宏观分析：通过 BFS 逆向计算全图每个格子到中心终点的绝对最短路径步数
	var target_pos = battle_manager.target_tile
	var grid = battle_manager.game_area.game_grid
	var distance_map_to_target = _calculate_global_distance_field(target_pos, battle_manager)
	
	var players_strategic_info = []
	for p in battle_manager.players:
		if is_instance_valid(p):
			var dist = distance_map_to_target.get(p.current_tile, 99)
			players_strategic_info.append({
				"player_id": p.player_id + 1,
				"is_current_turn": (p.player_id == player_idx),
				"distance_to_goal": dist
			})

	# 5. 获取当前玩家的脚下地块
	var current_unit = battle_manager.get_current_player()
	var current_terrain = "未知"
	if grid.grid_data.has(current_unit.current_tile):
		var current_tile_data = grid.grid_data[current_unit.current_tile]
		current_terrain = grid.get_terrain_string(current_tile_data["terrain"]).to_upper()
	
	# 6. 将当前操作玩家的所有手牌格式化，准备提交给 DeepSeek
	var hand_info_list = []
	for i in range(current_hand_cards.size()):
		var card = current_hand_cards[i]
		if is_instance_valid(card):
			var c_name = card.get_node("Name").text if card.has_node("Name") else "未知"
			var c_color = card.get_node("Color").text if card.has_node("Color") else "无"
			var c_func = card.get_node("Function").text if card.has_node("Function") else "无"
			var is_legal = (c_color == "UNIVERSAL" or c_color == "万能" or c_color == current_terrain)
			
			hand_info_list.append({
				"index": i, 
				"name": c_name, 
				"color": c_color, 
				"type": c_func,
				"can_be_played_on_current_tile_now": is_legal
			})

	# 7. 🎭 针对出牌与弃牌注入不同的战略 Prompt
	var system_prompt = ""
	var user_prompt = ""
	
	if is_discard_phase:
		system_prompt = "你是一款Uno规则结合战棋竞速型游戏的高级AI智囊。当前对局处于回合末的‘强制弃牌环节’，玩家手牌超过了5张上限。你的任务是分析当前的局势与他的地形，帮他从手牌里挑出一张‘当前用不上、未来几轮内由于地块颜色不匹配最难打出、最没有保留价值’的卡牌，并给出中文幽默弃牌理由。"
		user_prompt = "=== 弃牌阶段核心内幕 ===\n"
		user_prompt += "【选手距终点步数】:%s\n" % JSON.stringify(players_strategic_info)
		user_prompt += "【正在承受弃牌惩罚】: 玩家 %d\n" % (player_idx + 1)
		user_prompt += "【该玩家当前立足地形】: 【%s】\n" % current_terrain
		user_prompt += "【当前多余的手牌列表】:\n%s\n\n" % JSON.stringify(hand_info_list)
		user_prompt += "请从中选出一张【最适合丢弃】的卡牌索引（recommended_index）。\n"
		user_prompt += '必须严格按照以下 JSON 格式回复，绝对不要带有 markdown 标签：\n{"recommended_index": 应该扔掉的卡牌 index 数字, "reason": "幽默且专业的中文弃牌断舍离指南"}'
	else:
		system_prompt = "你是一款融合了Uno规则与战棋竞速的精品游戏AI大军师。游戏核心目标是让自己的棋子率先走到棋盘中心的终点。出牌规则：除UNIVERSAL(万能)外，卡牌颜色必须与玩家脚下的地形严格一致！你需要结合手牌的合法性以及三位选手的距离，给出一项一针见血的顶级出牌建议。"
		user_prompt = "=== 出牌阶段核心内幕 ===\n"
		user_prompt += "【战场各选手距终点步数】:%s\n" % JSON.stringify(players_strategic_info)
		user_prompt += "【当前操作轮次】: 轮到 玩家 %d 行动。\n" % (player_idx + 1)
		user_prompt += "【该玩家当前立足地形】: 【%s】\n" % current_terrain
		user_prompt += "【当前可供打出的手牌列表】:\n%s\n\n" % JSON.stringify(hand_info_list)
		user_prompt += "请从中选出一张【最适合用来打出】的卡牌。如果觉得无牌可出，推荐 index 填 -1。\n"
		user_prompt += '必须严格按照以下 JSON 格式回复，绝对不要带有 markdown 标签：\n{"recommended_index": 推荐卡牌的 index 数字, "reason": "带有一针见血、高策略度的中文出牌策略"}'

	# 8. 发送异步网络请求到大模型端点
	_send_deepseek_request(system_prompt, user_prompt, current_hand_cards)

## 🛠️ 内部算法进阶：利用 BFS 逆向计算全图所有地块到终点的精确步数
func _calculate_global_distance_field(target: Vector2i, bm) -> Dictionary:
	var visited = {target: 0}
	var queue = [target]
	var grid = bm.game_area.game_grid
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_dist = visited[current]
		
		# 利用你项目里现有的获取周围格子方法
		var neighbors = bm.game_area.get_surrounding_cells(current)
		for n in neighbors:
			if not visited.has(n) and grid.grid_data.has(n):
				var cell = grid.get_cell_data(n)
				# 如果没有无黑洞障碍阻挡，则是可达路径
				if cell["obstacle"] == GameGrid.Obstacle.NULL:
					visited[n] = current_dist + 1
					queue.push_back(n)
	return visited


## 异步发送网络请求（修复Godot 4.x信号报错）
func _send_deepseek_request(system_prompt: String, user_prompt: String, hand_cards: Array) -> void:
	# 每次请求前先销毁旧的请求节点，彻底避免信号重复连接问题
	if ai_http_request and is_instance_valid(ai_http_request):
		ai_http_request.queue_free()
	
	# 创建全新的HTTPRequest节点（每次请求都用新节点，不会有信号冲突）
	ai_http_request = HTTPRequest.new()
	ai_http_request.name = "AI_HTTPRequest"
	add_child(ai_http_request)

	# 直接连接信号（新节点无历史连接，不会报错）
	ai_http_request.request_completed.connect(_on_deepseek_response.bind(hand_cards))

	var headers = ["Content-Type: application/json", "Authorization: Bearer " + DEEP_SEEK_API_KEY]
	var body = {
		"model": "deepseek-v4-flash",
		"messages": [
			{"role": "system", "content": system_prompt},
			{"role": "user", "content": user_prompt}
		],
		"temperature": 0.5,
		"response_format": {"type": "json_object"}
	}

	var error = ai_http_request.request(DEEP_SEEK_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		print("[AI 错误] HTTP 启动请求失败: ", error)


## 异步网络回调
func _on_deepseek_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, hand_cards: Array) -> void:
	if response_code != 200:
		print("[AI 错误] API 返回异常，状态码: %d" % response_code)
		return

	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return

	var response_data = json.get_data()
	var ai_message = response_data["choices"][0]["message"]["content"]
	
	var ai_json = JSON.new()
	if ai_json.parse(ai_message) == OK:
		var result_dict = ai_json.get_data()
		var rec_index = int(result_dict.get("recommended_index", -1))
		var reason = result_dict.get("reason", "")
		
		print("\n============= 🤖 DeepSeek 大局观军师 =============\n")
		Toast.show(reason)
		
		if rec_index >= 0 and rec_index < hand_cards.size():
			var target_card = hand_cards[rec_index]
			_play_ai_hint_animation(target_card)
		else:
			print("🤖 局势观察：由于地块死锁或局势恶劣，手里没有能用的牌。建议直接点 PASS 摸牌苟住！")
		print("==================================================\n")


func _play_ai_hint_animation(card):
	var original_scale = card.scale
	var tween = create_tween().set_loops(2)
	tween.tween_property(card, "scale", original_scale * 1.15, 0.15)
	tween.tween_property(card, "scale", original_scale, 0.15)
