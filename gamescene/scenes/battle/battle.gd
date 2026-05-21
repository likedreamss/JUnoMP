extends Node2D
class_name Battle
#version1.0.0
enum GameMode { MOVE, PLACE_OBSTACLE,REMOVE_OBSTACLE,CHANGE_TERRAIN}

# --- 导出变量 ---
@export_group("Setup")
@export var target_tile: Vector2i = Vector2i(0, 0) # 终点设为中心点 [cite: 6]
@export var game_area: GameArea 
@export var unit_scene: PackedScene 
@export var highlight_scene: PackedScene 

@onready var panel: Panel = $提示/Panel
@onready var winner_label: Label = $提示/Panel/winner_label
@onready var time_label: Label = $提示/Panel/time_label
@onready var step_label: Label = $提示/Panel/step_label

#控制鼠标缩放
@export var zoom_speed: float = 0.1       # 缩放步长
@export var min_zoom: float = 0.4          # 最小缩放（看全景）
@export var max_zoom: float = 2.0          # 最大缩放（看细节）
# --- 变量定义 ---
var target_zoom: float = 1.0
var active_highlights: Array = [] 
var players: Array = [] 
var current_player_index: int = 0 
var current_mode = GameMode.MOVE
var next_player 
var _player_id = 0
var player_id_count = 0
var pending_type = null# 用于临时存储卡牌带入的地形或障碍物类型
# --- 结算页面变量 ---
var game_start_time: float = 0
var total_steps: int = 0
var game_finished: bool = false
var waiting: bool = false #用来禁止跳过
var has_moved_this_turn: bool = false # 记录本回合是否已执行过移动
var skip_flags = {
	"turn": [],     # 存储需要跳过回合的 player_id
	"draw": [],     # 跳过摸牌阶段
	"play": [],     # 跳过出牌阶段
	"discard": []   # 跳过弃牌阶段
}

## 初始化游戏界面（棋子，地图）---------------
func spawn_players():
	var grid_dict = game_area.game_grid.get_all_grid_data() 
	var all_valid_tiles = grid_dict.keys()
	
	# 安全检查：防止地图未生成导致报错 
	if all_valid_tiles.size() == 0:
		print("❌ 错误：地图数据为空，无法生成玩家")
		return

	# 预设的边缘大致方向 [cite: 20]
	var spawn_directions = [
		Vector2i(-12, -6), # 左上方向 
		Vector2i(12, -6),  # 右上方向 
		Vector2i(0, 12)    # 下方方向
	]
	
	for i in range(3):
		var unit = unit_scene.instantiate()
		unit.move_finished.connect(_on_unit_move_finished) 
		add_child(unit) 
		unit.setup(i) 
		
		# 寻找离预设边缘方向最近的有效瓦片，防止 Key 报错 [cite: 32, 33]
		var target_dir = spawn_directions[i]
		var start_tile = all_valid_tiles[0] 
		var min_dist = 9999.0 
		
		for tile in all_valid_tiles:
			var d = Vector2(tile).distance_to(Vector2(target_dir))
			var data = grid_dict[tile] 
			# 确保起始点没有障碍物 [cite: 40]
			if d < min_dist and data["obstacle"] == GameGrid.Obstacle.NULL:
				min_dist = d
				start_tile = tile
		
		# 设置位置并同步数据字典 [cite: 44, 45]
		unit.set_tile(start_tile, game_area) 
		game_area.game_grid.grid_data[start_tile]["unit"] = unit
		players.append(unit) 
		next_player = players[current_player_index]
func _ready():
	add_to_group("battle_manager")#方便卡牌管理器找到
	
	# 1. 强制确保地图数据在玩家生成前初始化完成 
	if game_area and game_area.game_grid:
		game_area.game_grid._initialize_grid() 
	# 2. 生成玩家
	spawn_players()
	var unit = get_current_player()
	var current_tile_data = game_area.game_grid.grid_data[unit.current_tile]
	var current_terrain_str = game_area.game_grid.get_terrain_string(current_tile_data["terrain"]).to_upper()
	get_tree().call_group("card0_UNIVERSAL","use_bool",1)
	get_tree().call_group("card0_"+str(current_terrain_str),"use_bool",1)
	# 3. 设置终点特效
	if has_node("TargetEffect"):
		var effect_pos = game_area.get_global_from_tile(target_tile) 
		$TargetEffect.position = effect_pos
	
	game_start_time = Time.get_ticks_msec() / 1000.0
	$"提示/Panel".visible = false
#回合循环/发牌/跳过
	highlight_current_unit()

##下一个玩家/发牌/跳过
func next_turn(loop_count: int = 0):
	# 如果连续跳过次数超过了玩家总数，强制中断死循环
	if loop_count >= players.size():
		print("⚠️ 警告：所有玩家都被跳过，回合强制推进以防死循环！")
		skip_flags["turn"].clear() 
		loop_count = 0 
		
	clear_highlights()
	current_player_index = (current_player_index + 1) % players.size()
	next_player = get_current_player()
	has_moved_this_turn = false 
	
	var id = (current_player_index + player_id_count) % players.size()
	_player_id = id - 1
	if _player_id < 0:
		_player_id = 2
		
	change_player_card(id)
	get_tree().call_group("card", "card_rotation")
	
	# 检查是否跳过整个回合(原地待命)
	if next_player.player_id in skip_flags["turn"]:
		skip_flags["turn"].erase(next_player.player_id)
		print("玩家 ", next_player.player_id, " 的回合被跳过")
		highlight_current_unit()
		get_tree().call_group("card" + str(id), "visible", 1)
		get_tree().call_group("card" + str(_player_id), "visible", 0)

		await get_tree().create_timer(0.6).timeout
		
		
		next_turn(loop_count + 1) 
		return
		
	get_tree().call_group("PASS", "pass_bool", 0)
	
	# 检查各阶段跳过逻辑 (釜底抽薪)
	if next_player.player_id in skip_flags["draw"]:
		skip_flags["draw"].erase(next_player.player_id)
		print("❌ 受到【釜底抽薪】影响，玩家 ", next_player.player_id, " 本回合跳过摸牌阶段！")
	else:
		_effect_draw_cardsa(id, 2) # 正常回合摸牌

	get_tree().call_group("card" + str(id), "visible", 1)
	get_tree().call_group("card" + str(_player_id), "visible", 0)

	# 【检查出牌阶段跳过】 (束手待毙)
	var unit = get_current_player()
	var current_tile_data = game_area.game_grid.grid_data[unit.current_tile]
	var current_terrain_str = game_area.game_grid.get_terrain_string(current_tile_data["terrain"]).to_upper()
	
	if next_player.player_id in skip_flags["play"]:
		skip_flags["play"].erase(next_player.player_id)
		print("❌ 受到【束手待毙】影响，玩家 ", next_player.player_id, " 本回合无法出牌！")
	else:
		# 正常出牌：解锁万能卡和当前地形对应的卡牌
		get_tree().call_group("card" + str(id) + "_UNIVERSAL", "use_bool", 1)
		get_tree().call_group("card" + str(id) + "_" + str(current_terrain_str), "use_bool", 1)
		show_move_range()

	highlight_current_unit()
	await get_tree().create_timer(1).timeout
	get_tree().call_group("PASS", "pass_bool", 1)
	
	
	
	
	
func get_current_player():
	return players[current_player_index] 

##出牌阶段input
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT: 
			_on_mouse_click() 
	_handle_zoom_input(event)#鼠标缩放
#移动控制
func _on_mouse_click():
	var clicked_tile = game_area.get_hovered_tile() 
	
	match current_mode:
		GameMode.MOVE:
			try_move_to_tile(get_current_player(),clicked_tile)
		GameMode.REMOVE_OBSTACLE:
			_try_remove_obstacle(clicked_tile)
		GameMode.PLACE_OBSTACLE:
			_try_place_obstacle(clicked_tile)
		GameMode.CHANGE_TERRAIN:
			_try_change_terrain(clicked_tile)
			
func try_move_to_tile(unit: Unit, target: Vector2i) -> void:
	if unit == null: return 
	
	# === ✨【核心修复：移动锁拦截】✨ ===
	# 如果本回合已经下达过移动指令，或者棋子正在平滑移动中，直接拦截一切点击
	if has_moved_this_turn:
		print("⏳ 棋子正在移动中，请稍后...")
		return
		
	# 检查字典中是否存在该坐标，防止黑洞报错 [cite: 650-652]
	if not game_area.game_grid.grid_data.has(target): 
		return

	var is_valid_move = false
	for hl in active_highlights:
		# 通过高亮物体的全局坐标还原其对应的 Tile 坐标进行比对 [cite: 656-657]
		if game_area.get_tile_from_global(hl.position) == target:
			is_valid_move = true
			break
	
	if not is_valid_move:
		print("❌ 只能移动到高亮锁定的范围内")
		return
		
	# 获取数据并检查障碍物 [cite: 663-664]
	var cell_data = game_area.game_grid.get_cell_data(target) 
	
	if cell_data["obstacle"] != GameGrid.Obstacle.NULL: 
		print("❌ 被障碍物阻挡")
		return
		
	if cell_data["unit"] != null: 
		print("❌ 位置已被占用")
		return

	# 确认可以移动后，在执行前瞬间清空棋盘所有选择高亮，防止高亮残留引发鼠标二次误触
	clear_highlights()
	# 执行物理和逻辑移动
	_execute_move(unit, target)
	
func _execute_move(unit: Unit, target: Vector2i) -> void: 
	has_moved_this_turn = true
	# 更新后端数据 
	game_area.game_grid.grid_data[unit.current_tile]["unit"] = null 
	game_area.game_grid.grid_data[target]["unit"] = unit 
	# 执行平滑位移
	unit.move_to_tile(target, game_area)
	# 检查胜负 
	check_victory(unit)

## 核心函数：卡牌效果执行
func execute_card_effect(effect_type: String, params: Dictionary = {}):
	var card_color_str = params.get("terrain_req", "UNIVERSAL") 
	match effect_type:
		"jump_two": # 功能1：只高亮距离为2的一圈
			show_custom_range(2, 2)
		"long_teleport": # 功能2：
			show_custom_range(3, 3)
		"无中生有":#抽两张牌
			var id = (current_player_index + player_id_count) % players.size()
			_effect_draw_cardsa(id,2)
			print(id)
			_reset_after_action()
			
		"重铸":
			var id = (current_player_index + player_id_count) % players.size()
			_effect_draw_cardsa(id,1)
			print(next_player.player_id)
			_reset_after_action()
			
		"化险为夷":#移除障碍物
			print("选择要移除障碍物的格子")
			current_mode=GameMode.REMOVE_OBSTACLE
			_show_removable_obstacles()
		
		"障碍重重":#设置障碍物
			current_mode = GameMode.PLACE_OBSTACLE
			pending_type = [GameGrid.Obstacle.MOUNTAIN, GameGrid.Obstacle.TREE, GameGrid.Obstacle.HOUSE].pick_random()
			_show_placeable_tiles()
			
		"点染一格":#单格改颜色
			current_mode = GameMode.CHANGE_TERRAIN
			if card_color_str == "UNIVERSAL":
				pending_type = -1 # 使用 -1 作为随机地形的标记
			else:
				# 映射字符串到地形枚举 
				var t_map = {"LAND": 0, "GRASS": 1, "PINK": 2, "RIVER": 3}
				pending_type = t_map.get(card_color_str, 0) 
			_show_all_tiles_for_paint()
	
		"skip_action":#跳过
			var target_id = params.get("target_id", -1)
			var phase = params.get("phase", "")
			if target_id != -1 and phase != "":
				_effect_add_skip(target_id, phase)
				
		"原地待命": # 跳过下一个玩家的整个回合（包含摸牌、出牌、移动、弃牌）
			var next_p_id = (current_player_index +1) % players.size()
			_effect_add_skip(next_p_id, "turn")
			print("触发【原地待命】：玩家 ", next_p_id, " 的整个回合将被跳过！")
			_reset_after_action() 

		"束手待毙": # 下一个玩家无法出牌 已完成
			var next_p_id = (current_player_index + 1) % players.size()
			_effect_add_skip(next_p_id, "play")
			print("触发【束手待毙】：玩家 ", next_p_id, " 下回合将无法出牌！")
			_reset_after_action()

		"韬光养晦": # 自己本回合结束时，跳过弃牌阶段 已完成
			var my_id = next_player.player_id
			_effect_add_skip(my_id, "discard")
			print("触发【韬光养晦】：玩家 ", my_id, " 本回合结束时无需弃牌！")
			_reset_after_action()

		"釜底抽薪": # 下一个玩家在下个回合开始时无法摸牌 已完成
			var next_p_id = (current_player_index + 1) % players.size()
			_effect_add_skip(next_p_id, "draw")
			print("触发【釜底抽薪】：玩家 ", next_p_id, " 下回合将无法摸牌！")
			_reset_after_action()
		
				
		"交换人生":
			
			get_tree().call_group("PASS","pass_bool",0)
			
			var id = (current_player_index + player_id_count+1) % players.size()
			_player_id = id - 1
			if _player_id < 0:
				_player_id = 2
			player_id_count += 1
			change_player_card(id)#玩家位置转换动画函数
			get_tree().call_group("card","card_rotation")#同上
			get_tree().call_group("card"+str(id),"visible",1)
			get_tree().call_group("card"+str(_player_id),"visible",0)#卡牌可操控变为不可操控
			
			var unit = get_current_player()
			var current_tile_data = game_area.game_grid.grid_data[unit.current_tile]
			var current_terrain_str = game_area.game_grid.get_terrain_string(current_tile_data["terrain"]).to_upper()
			get_tree().call_group("card"+str(id)+"_UNIVERSAL","use_bool",1)
			get_tree().call_group("card"+str(id)+"_"+str(current_terrain_str),"use_bool",1)

			await get_tree().create_timer(1).timeout
			get_tree().call_group("PASS","pass_bool",1)
			_reset_after_action()
		
		"乾坤重置":#重新生成地图
			game_area.game_grid.force_regenerate_map()
			_fix_units_after_regen()
			_reset_after_action()
			var unit = get_current_player()
			var current_tile_data = game_area.game_grid.grid_data[unit.current_tile]
			var current_terrain_str = game_area.game_grid.get_terrain_string(current_tile_data["terrain"]).to_upper()
			var id = (next_player.player_id + player_id_count) % players.size()
			get_tree().call_group("card"+str(id),"visible",0)
			get_tree().call_group("card"+str(id),"visible",1)
			get_tree().call_group("card"+str(id)+"_UNIVERSAL","use_bool",1)
			get_tree().call_group("card"+str(id)+"_"+str(current_terrain_str),"use_bool",1)
			
			
			
func _effect_recast():
	print("执行：重铸！换取1张新牌")
	get_tree().call_group("deck_manager","draw_card",1)
func _effect_add_skip(player_id: int, phase: String):
	# phase 可选: "turn", "draw", "play", "discard"
	if skip_flags.has(phase):
		skip_flags[phase].append(player_id)
		print("玩家 ", player_id, " 将跳过 ", phase)
func _effect_draw_cards(count: int):
	print("执行：获得 ", count, " 张牌")
	get_tree().call_group("deck","draw_card",count)

func _effect_draw_cardsa(player_id,count):#为不同玩家发牌
	match player_id:
		0:
			print("执行：玩家0获得 ", count, " 张牌")
			get_tree().call_group("deck"+str(player_id),"draw_card",count)
		1:
			print("执行：玩家1获得 ", count, " 张牌")
			get_tree().call_group("deck"+str(player_id),"draw_card",count)
		2:
			print("执行：玩家2获得 ", count, " 张牌")
			get_tree().call_group("deck"+str(player_id),"draw_card",count)
	var unit = get_current_player()
	var current_tile_data = game_area.game_grid.grid_data[unit.current_tile]
	var current_terrain_str = game_area.game_grid.get_terrain_string(current_tile_data["terrain"]).to_upper()
	get_tree().call_group("card"+str(player_id)+"_UNIVERSAL","use_bool",1)
	get_tree().call_group("card"+str(player_id)+"_"+str(current_terrain_str),"use_bool",1)
	
	
func change_player_card(player_id):
	get_tree().call_group("player_hand","player_card_change",player_id)

	
##回合结束与结果判定
func _on_unit_move_finished():
	get_tree().call_group("cardmanager","delate_card_animate")
	await get_tree().create_timer(0.5).timeout
	discard_turn()#进入弃牌回合


func discard_turn():#弃牌判定
	var player = get_current_player()
	
	if player.player_id in skip_flags["discard"]:
		skip_flags["discard"].erase(player.player_id)
		print("受到【韬光养晦】保护，玩家 ", player.player_id, " 略过弃牌环节，直接进入下一回合！")
		next_turn()
		return
	
	var id = (player.player_id + player_id_count) % players.size() 
	var group_name = "player_hand" + str(id)
	var player_hand = get_tree().get_nodes_in_group(group_name)
	var card_nume = 0
	clear_highlights()
	if player_hand.size() >0:
		card_nume = player_hand[0].get_playerhand_size()  # ✅ 正确：对单个节点调用
	print(card_nume)
	if card_nume > 5:
		discard_start(card_nume - 5,id)
	else:
		print("无需弃牌")
		next_turn() 

func discard_start(discard_nume,player_id):#执行弃牌
	highlight_current_unit()
	print("请弃牌"+str(discard_nume)+"张")
	get_tree().call_group("PASS","pass_bool",0)
	get_tree().call_group("card"+str(player_id),"use_bool",1)
	while discard_nume > 0:
		await get_tree().create_timer(0.6).timeout
		var least_nume = discard_nume_count(discard_nume)
		discard_nume = least_nume
		print("请弃牌"+str(discard_nume)+"张")
		
	print("弃牌完成")
	await get_tree().create_timer(0.6).timeout
	
	
	next_turn() 

func discard_nume_count(nume):
	
	var card_manager = get_tree().get_nodes_in_group("cardmanager")
	var least_nume = card_manager[0].discard_card(nume)
	return least_nume


func delate_card_animate():
	get_tree().call_group("cardmanager","delate_card_animate")

	

func check_victory(unit: Unit):
	if unit.current_tile == target_tile: 
		print("🎉 玩家 ", unit.player_id, " 到达终点，获得胜利！") 
		set_process_input(false) 
		game_finished = true
		set_process_input(false)
		show_result_panel(unit.player_id)




#显示可移动范围/高亮
func _get_tiles_in_range(center: Vector2i, max_range: int) -> Dictionary:
	var visited = {center: 0} # 格式: {坐标: 距离}
	var queue = [center]
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var current_dist = visited[current]
		
		if current_dist < max_range:
			# 使用 Godot 自带的邻居获取函数，最保险
			var neighbors = game_area.get_surrounding_cells(current)
			for n in neighbors:
				if not visited.has(n) and game_area.game_grid.grid_data.has(n):
					visited[n] = current_dist + 1
					queue.push_back(n)
	return visited
# 普通移动：距离为 1
func show_move_range():
	clear_highlights()
	var unit = get_current_player()
	var player_color = [Color.RED, Color.GREEN, Color.BLUE][unit.player_id]
	# 获取距离为 1 的所有格子
	var range_data = _get_tiles_in_range(unit.current_tile, 1)
	for tile in range_data:
		if range_data[tile] == 0: continue # 跳过自己
		var data = game_area.game_grid.grid_data[tile]
		if data["obstacle"] == GameGrid.Obstacle.NULL and data["unit"] == null:
			_spawn_highlight_at(tile, player_color)
# 特殊移动：基于 BFS 的精确距离
func show_custom_range(min_r: int, max_r: int):
	clear_highlights()
	var unit = get_current_player()
	
	# 1. 算出最大范围内的所有格子
	var range_data = _get_tiles_in_range(unit.current_tile, max_r)
	
	# 2. 筛选出符合最小距离条件的格子
	for tile in range_data:
		var dist = range_data[tile]
		if dist >= min_r and dist <= max_r:
			var data = game_area.game_grid.grid_data[tile]
			if data["obstacle"] == GameGrid.Obstacle.NULL and data["unit"] == null:
				_spawn_highlight_at(tile, Color.PURPLE)

func _spawn_highlight_at(tile: Vector2i, color: Color):
	var hl = highlight_scene.instantiate()
	add_child(hl) 
	hl.position = game_area.get_global_from_tile(tile)
	hl.modulate = color
	hl.modulate.a = 0.5 
	active_highlights.append(hl)

func clear_highlights():
	for hl in active_highlights: 
		if is_instance_valid(hl): hl.queue_free() 
	active_highlights.clear()
#鼠标缩放功能
func _handle_zoom_input(event: InputEvent):
	if not event is InputEventMouseButton or not event.pressed:
		return

	var camera = $Camera2D # 获取相机节点
	var zoom_changed = false

	# 判定滚轮向上（放大）
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		target_zoom = min(target_zoom + zoom_speed, max_zoom)
		zoom_changed = true
	# 判定滚轮向下（缩小）
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		target_zoom = max(target_zoom - zoom_speed, min_zoom)
		zoom_changed = true

	# 如果缩放值发生变化，执行平滑动画
	if zoom_changed:
		var tween = create_tween() # 使用你惯用的 Tween 逻辑 
		tween.tween_property(camera, "zoom", Vector2(target_zoom, target_zoom), 0.15)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)



##控制棋子移动--------------------
##新增：接收从 UI 打出的卡牌 
func play_card_from_ui(card_data: Array):
	var terrain_req = card_data[0] # 例如: "LAND", "UNIVERSAL", "GRASS"
	var card_type = card_data[1]   # 例如: "GO", "TRICK"
	var card_name = card_data[2]   # 例如: "前进2格"

	# 获取当前玩家和脚下的地形
	var unit = get_current_player()
	var current_tile_data = game_area.game_grid.grid_data[unit.current_tile]
	var current_terrain_str = game_area.game_grid.get_terrain_string(current_tile_data["terrain"]).to_upper()
	
	
	# 【规则 1：起步地形一致性校验】
	# 如果卡牌不是 UNIVERSAL，且玩家脚下地形与卡牌属性不一致，则禁止出牌
	if terrain_req != "UNIVERSAL" and terrain_req != current_terrain_str:
		print("❌ 出牌失败：你站在 [", current_terrain_str, "]，无法打出 [", terrain_req, "] 属性的卡牌！")
		# 注意：目前你的 UI 会直接把牌删掉。后续可以在这里给 UI 返回 false 让卡牌弹回手牌
		return 

	print("✅ 出牌成功：触发卡牌 -> ", card_name)
	
	waiting = true # 开始显示高亮，进入等待输入状态
	get_tree().call_group("PASS", "pass_bool", 0) # 禁用跳过按钮 
	# --- 执行卡牌逻辑 ---
	if card_type == "GO":
		var dist = 1
		if "2" in card_name: dist = 2
		elif "3" in card_name: dist = 3
		show_move_range_for_card(dist)
	elif card_type == "TRICK":
		execute_card_effect(card_name, {"terrain_req": terrain_req})
	
	
		
##受卡牌控制的高亮显示逻辑 
func show_move_range_for_card(distance: int):
	clear_highlights()
	var unit = get_current_player()
	var highlight_color = [Color.RED, Color.GREEN, Color.BLUE][unit.player_id]
	if distance > 1:
		highlight_color = Color.PURPLE 

	# 使用 BFS 获取最大范围内的所有格子
	var range_data = _get_tiles_in_range(unit.current_tile, distance)

	for tile in range_data:
		var dist_to_tile = range_data[tile]
		
		# 【规则 2：跳跃逻辑】只高亮处于最边缘的圆环
		if dist_to_tile != distance: 
			continue 
			
		var data = game_area.game_grid.grid_data[tile]
		
		# 【规则 3：终点地形自由】
		# 不再校验地形！只要没有障碍物且没有其他玩家占用，就可以走过去
		if data["obstacle"] == GameGrid.Obstacle.NULL and data["unit"] == null:
			_spawn_highlight_at(tile, highlight_color)

##移除障碍物
## --- 新增：高亮所有可以被移除的障碍物 ---
func _show_removable_obstacles():
	clear_highlights()
	
	# 遍历地图上所有的格子
	for tile in game_area.game_grid.grid_data:
		var data = game_area.game_grid.grid_data[tile]
		# 如果这个格子上确实有障碍物
		if data["obstacle"] != GameGrid.Obstacle.NULL:
			# 用特殊的颜色高亮它（比如黄色，代表警告/可交互）
			_spawn_highlight_at(tile, Color.YELLOW)

## --- 新增：玩家点击目标后的移除逻辑 ---
func _try_remove_obstacle(target: Vector2i):
	# 1. 安全校验：检查点击的格子是否在高亮范围内
	var is_valid_target = false
	for hl in active_highlights:
		if game_area.get_tile_from_global(hl.position) == target:
			is_valid_target = true
			break
			
	if not is_valid_target:
		return
		
	# 2. 执行移除操作：调用 GameGrid 已经写好的接口
	game_area.game_grid.set_tile_obstacle(target, GameGrid.Obstacle.NULL)
	print("✅ 障碍物已成功移除！")
	# 3. 恢复游戏状态
	clear_highlights()
	current_mode = GameMode.MOVE # 别忘了把模式切回默认的移动模式
	_reset_after_action()
##障碍重重逻辑
func _show_placeable_tiles():
	clear_highlights()
	for tile in game_area.game_grid.grid_data:
		var data = game_area.game_grid.grid_data[tile]
		# 只有没有障碍物且没有玩家的地块才能放障碍
		if data["obstacle"] == GameGrid.Obstacle.NULL and data["unit"] == null:
			_spawn_highlight_at(tile, Color.ORANGE)

func _try_place_obstacle(target: Vector2i):
	if _is_click_on_highlight(target):
		game_area.game_grid.set_tile_obstacle(target, pending_type)
		_reset_after_action()

##点染一格逻
func _show_all_tiles_for_paint():
	clear_highlights()
	for tile in game_area.game_grid.grid_data:
		# 全图除玩家脚下外基本都能染色
		_spawn_highlight_at(tile, Color.AQUA)

func _try_change_terrain(target: Vector2i):
	if _is_click_on_highlight(target):
		var final_terrain = pending_type
		# 如果是万能牌效果，随机生成一个 0-3 的地形索引 
		if final_terrain == -1:
			final_terrain = randi() % 4 
			print("万能点染：目标随机变为了地形索引 ", final_terrain)
		game_area.game_grid.set_tile_terrain(target, final_terrain)
		_reset_after_action()

##乾坤重置后的辅助修复
func _fix_units_after_regen():
	for unit in players:
		if game_area.game_grid.grid_data.has(unit.current_tile):
			game_area.game_grid.set_tile_obstacle(unit.current_tile, GameGrid.Obstacle.NULL)
			game_area.game_grid.grid_data[unit.current_tile]["unit"] = unit 
	

#通用辅助
func _is_click_on_highlight(target: Vector2i) -> bool:
	for hl in active_highlights:
		if game_area.get_tile_from_global(hl.position) == target:
			return true
	return false

func _reset_after_action():
	clear_highlights()
	current_mode = GameMode.MOVE
	pending_type = null
	waiting=false
	get_tree().call_group("PASS","pass_bool",1)
	delate_card_animate()
	highlight_current_unit()
# 显示结算面板
func show_result_panel(winner_id):

	var panel = $"提示/Panel"

	panel.visible = true

	$"提示/Panel/winner_label".text = "玩家 %d 胜利！" % winner_id

	var total_time = Time.get_ticks_msec() / 1000.0 - game_start_time

	var total_seconds = int(total_time)

	var minutes = int(total_seconds / 60)

	var seconds = total_seconds % 60

	$"提示/Panel/time_label".text = "游戏耗时：%02d:%02d" % [minutes, seconds]

	$"提示/Panel/step_label".text = "移动步数：%d" % total_steps
# 返回菜单
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("C:/Users/Kris/Documents/j-uno-mp游戏界面/meun.gd")


func highlight_current_unit():
	# 1. 核心修复：强制清除上一轮遗留的所有高亮，防止多玩家高亮重叠残留
	clear_highlights()
	
	# 2. 安全检查：防止在游戏初始化或重置的极端空隙中发生空指针崩溃
	var unit = get_current_player()
	if unit == null:
		return
		
	# 3. 动态色彩机制：根据玩家当前的实际状态，让脚底的阵营高亮圈产生智能变化
	var highlight_color = [Color.RED, Color.GREEN, Color.BLUE][unit.player_id] # 默认阵营基础色
	
	# 如果该玩家的整个回合都在跳过队列中（被“原地待命”锁定）
	if unit.player_id in skip_flags["turn"]:
		highlight_color = Color.GRAY # 灰色：代表该棋子本轮直接瘫痪/跳过
	# 如果该玩家下回合被禁出牌（受到“束手待毙”惩罚）
	elif unit.player_id in skip_flags["play"]:
		highlight_color = Color.ORANGE # 橙色/警告色：提示玩家该棋子只能移动、无法出牌
		
	# 4. 精准在当前操作玩家的后端物理瓦片坐标上，渲染对应的视觉高亮特效
	_spawn_highlight_at(unit.current_tile, highlight_color)
