extends Node
class_name GameGrid

# 对应地形和障碍物顺序
enum Terrain {LAND, GRASS, PINK, RIVER}
enum Obstacle {MOUNTAIN, TREE, HOUSE, NULL}
#导出变量
@export_group("Layers")
@export var main_tile_map: TileMapLayer
@export var obstacle_tile_map: TileMapLayer
#内部变量
var noise = FastNoiseLite.new()
var grid_data: Dictionary = {}


var obscale_num = 0.2 #影响障碍物数量

## 生成地形
func _initialize_grid() -> void:
	
	grid_data.clear()
	main_tile_map.clear()
	if obstacle_tile_map: obstacle_tile_map.clear()

	var land_cells: Array[Vector2i] = []
	var grass_cells: Array[Vector2i] = []
	var river_cells: Array[Vector2i] = []
	var pink_cells: Array[Vector2i] = []

	var size = 12 
	noise.frequency = 0.5 

	# --- 核心修复：六边形网格双层循环 ---
	# q 轴 (横向)
	for q in range(-size, size + 1):
		# r 轴 (斜向)
		# 计算 r 的范围，确保六边形闭合
		for r in range(-size, size + 1):
			# 六边形 axial 距离公式：|q| + |r| + |s| = 2*size
			# 其中 s = -q - r
			if abs(q) + abs(r) + abs(-q - r) <= 2 * size:
				var pos = Vector2i(q, r) # Hex axial coordinates
				
				var n_val = noise.get_noise_2d(float(q), float(r)) + randf_range(-0.05, 0.05)
				
				var t_type = Terrain.LAND
				var o_type = Obstacle.NULL

				# --- 地形分配 ---
				if n_val < -0.15:
					t_type = Terrain.RIVER
					river_cells.append(pos) 
				elif n_val > 0.2:
					t_type = Terrain.PINK
					pink_cells.append(pos)
				elif n_val > 0.05:
					t_type = Terrain.GRASS
					grass_cells.append(pos) 
				else:
					t_type = Terrain.LAND
					land_cells.append(pos) 

				# --- 障碍物分配 ---
				if t_type != Terrain.RIVER and randf() < obscale_num: 
					var obs_list = [Obstacle.MOUNTAIN, Obstacle.TREE, Obstacle.HOUSE] 
					o_type = obs_list.pick_random() 

				# 存入数据
				grid_data[pos] = {"unit": null, "terrain": t_type, "obstacle": o_type} 
	# --- 结束核心修复 ---

	# 执行渲染
	for pos in land_cells:
		main_tile_map.set_cell(pos, 0, Vector2i(0,0))

	for pos in grass_cells:
		main_tile_map.set_cell(pos, 0, Vector2i(0,4))

	for pos in pink_cells:
		main_tile_map.set_cell(pos, 0, Vector2i(0,12))

	for pos in river_cells:
		main_tile_map.set_cell(pos, 0, Vector2i(0,10))

	for pos in grid_data: 
		if grid_data[pos].obstacle != Obstacle.NULL: 
			_update_obstacles_visual(pos, grid_data[pos].obstacle) 

## 接口：彻底重新生成地图
func force_regenerate_map():
	# 1. 改变噪声种子，确保每次调用生成全新的地形斑块
	randomize() 
	noise.seed = randi() 
	# 2. 调用现有的初始化逻辑重新绘制
	_initialize_grid()

func _ready() -> void:
	if not main_tile_map:
		return
	
	randomize()
	noise.seed = randi()
	noise.frequency = 2 # 决定地形斑块的大小
	noise.fractal_octaves = 5
	_initialize_grid()



# 数据查询接口 
func get_cell_data(cell_pos: Vector2i) -> Dictionary:
	return grid_data.get(cell_pos, {})
func get_all_grid_data() -> Dictionary:
	return grid_data
func get_terrain_string(terrain_val: int) -> String:
	var key = Terrain.find_key(terrain_val)
	return key.to_lower() if key else "unknown"
func get_obstacle_string(obstacle_val: int) -> String:
	var key = Obstacle.find_key(obstacle_val)
	if key:
		return str(key).to_lower()
	return "none"


## 接口：修改单格地形颜色
func set_tile_terrain(pos: Vector2i, new_terrain: Terrain):
	if grid_data.has(pos):
		grid_data[pos]["terrain"] = new_terrain
		_update_main_tile_visual(pos, new_terrain) 
## 接口：设置/消除障碍物
func set_tile_obstacle(pos: Vector2i, ob_type: Obstacle) -> bool:
	if not grid_data.has(pos):
		return false
		
	# 核心防错：如果是要【放置】障碍物（非 NULL），必须检查该地块是否已有玩家
	if ob_type != Obstacle.NULL and grid_data[pos]["unit"] != null:
		print("❌ 放置失败：该位置已被玩家 ", grid_data[pos]["unit"].player_id, " 占用！")
		return false
		
	grid_data[pos]["obstacle"] = ob_type
	_update_obstacles_visual(pos, ob_type)
	return true

#视觉渲染
func _update_main_tile_visual(cell_pos: Vector2i, t_type: int):
	if not main_tile_map: return
	
	# 根据地形枚举匹配对应的图块坐标 [cite: 244-250]
	var atlas_coords = Vector2i(0, 0)
	match t_type:
		Terrain.LAND: atlas_coords = Vector2i(0, 0)
		Terrain.GRASS: atlas_coords = Vector2i(0, 4)
		Terrain.PINK: atlas_coords = Vector2i(0, 12)
		Terrain.RIVER: atlas_coords = Vector2i(0, 10)
	
	main_tile_map.set_cell(cell_pos, 0, atlas_coords)
func _update_obstacles_visual(cell_pos: Vector2i, o_type: int):
	if not obstacle_tile_map: return

	if o_type == Obstacle.NULL:
		obstacle_tile_map.set_cell(cell_pos, -1)
		return

	var source_id = 1

	# 把每个类型的所有图块定义成数组
	var tile_options: Dictionary = {
		Obstacle.MOUNTAIN: [Vector2i(0, 4), Vector2i(2, 4)],
		Obstacle.TREE: [Vector2i(0, 6), Vector2i(4, 6), Vector2i(2, 8)],
		Obstacle.HOUSE: [Vector2i(0, 2), Vector2i(4, 4)]
	}

	# 随机选一个
	var atlas_coords: Vector2i = tile_options[o_type].pick_random()

	obstacle_tile_map.set_cell(cell_pos, source_id, atlas_coords)
