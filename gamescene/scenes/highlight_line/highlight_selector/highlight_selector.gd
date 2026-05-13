extends HighlightLine
class_name HighlightSelector



@export var game_area:GameArea
@onready var label_1: Label = $"Label_1"
@onready var label_2: Label = $"Label_2"
@onready var label_3: Label = $"Label_3"


var last_tile: Vector2i = Vector2i(0, 0)

func _process(_delta: float) -> void:
	if not game_area:
		return

	# 每帧都获取鼠标指向的瓦片（关键！）
	var current_tile = game_area.get_hovered_tile()

	# 只在坐标变化时更新文字（节省性能）
	if current_tile != last_tile:
		last_tile = current_tile
		var tile_position = game_area.get_global_from_tile(current_tile)
		position = tile_position
		_update_labels(current_tile)
		 

func _update_labels(tile_pos: Vector2i) -> void:
	if not game_area:
		return
		
	label_1.text = "(%d, %d)" % [tile_pos.x, tile_pos.y]
	if not game_area.game_grid:
		return
		
	var cell_data=game_area.game_grid.get_cell_data(tile_pos)
	if not cell_data.is_empty():
		var terrain=cell_data.get("terrain")
		var obstacle=cell_data.get("obstacle")
		
		if terrain !=null:
			label_2.text=game_area.game_grid.get_terrain_string(terrain)
		else:
			label_2.text="unknown"
		
		if obstacle !=null:
			label_3.text=game_area.game_grid.get_obstacle_string(obstacle)
		else:
			label_3.text="unknown"	
		
		# 如果悬停在终点，选择器变红/金
		if tile_pos == get_parent().target_tile:
			self.modulate = Color.GOLD
		else:
			self.modulate = Color.WHITE
		
