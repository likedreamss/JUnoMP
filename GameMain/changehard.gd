extends OptionButton
static var selected1 =0 
	
	
	
func _on_item_selected(index: int) -> void:
	match index:
		0: 
			GameGrid.obscale_num = 0.21
			selected1 = 0
		1:
			GameGrid.obscale_num = 0.11
			selected1 = 1
		2: 
			GameGrid.obscale_num = 0.32
			selected1 = 2
		3: 
			GameGrid.obscale_num = 0.4
			selected1 = 3
	Toast.show("障碍物密度已设置为: ", GameGrid.obscale_num)
	# 调用实例方法
	#if GameGrid.instance:
		#GameGrid.instance.force_regenerate_map()
	#else:
		#Toast.show("❌ GameGrid 实例未初始化，请检查 _ready() 函数")
		#pass
