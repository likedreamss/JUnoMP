extends OptionButton
static var selected1 =0 
	
	
	
func _on_item_selected(index: int) -> void:
	match index:
		0: 
			GameGrid.obscale_num = 0.21
			selected1 = 0
			Toast.show("障碍物密度已设置为: ", GameGrid.obscale_num)
		1:
			GameGrid.obscale_num = 0.11
			selected1 = 1
			Toast.show("障碍物密度已设置为: ", GameGrid.obscale_num)
		2: 
			GameGrid.obscale_num = 0.32
			selected1 = 2
			Toast.show("障碍物密度已设置为: ", GameGrid.obscale_num)
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
		
static var selected_bg = 0


func _on_background_item_selected(index: int) -> void:
	match index:
		0:
			$"../../../Background/backpic".texture = preload("res://QYK/Assest1/死亡搁浅.png")
			$"../../../BGM1".stream = preload("res://QYK/Assest1/李神无敌乐.mp3")
			$"../../../BGM1".play()
			selected_bg = 0

		1:
			$"../../../Background/backpic".texture = preload("res://QYK/Assest1/OCTOPATH TRVELER.png")
			$"../../../BGM1".stream = preload("res://QYK/Assest1/八方旅人.mp3")
			$"../../../BGM1".play()
			selected_bg = 1

		2:
			$"../../../Background/backpic".texture = preload("res://QYK/Assest1/ELDEN.jpg")
			$"../../../BGM1".stream = preload("res://QYK/Assest1/齋藤司 - Morgott, the Omen King.mp3")
			$"../../../BGM1".play()
			selected_bg = 2

		3:
			$"../../../Background/backpic".texture = preload("res://QYK/Assest1/YMCA.jpg")
			$"../../../BGM1".stream = preload("res://QYK/Assest1/Village People - Y.M.C.A (1).mp3")
			$"../../../BGM1".play()
			selected_bg = 3
	Toast.show("背景已切换")
