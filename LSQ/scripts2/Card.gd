extends Node2D

signal hovered
signal hovered_off

const card = 0

var start_rot: float = 0.0
# 目标旋转角度 120度 转弧度
const TARGET_ROT: float = deg_to_rad(120)
# 旋转速度
var usebool = 0
const ROT_SPEED: float = 5.0
var label_rotation_bool = 0
var rotation_bool = 0
var hower_bool = 0
var aaa = 0
var bbb
var starting_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# all cards must be a child of cardmannagere or error!!!!!!!!!!!!!!!!!!!!!!!!!
	add_to_group("card")
	add_to_group("card0")
	get_parent().connect_card_signals(self)
	$Code.visible =  false
	$Color.visible =  false
	$Function.visible =  false



# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	if label_rotation_bool:
		$Label.rotation += 3 * delta
	if rotation_bool:
		# 目标节点统一转到固定偏移
		var target = start_rot + TARGET_ROT
		# 平滑插值往目标角度靠，精准无误差
		$Area2D/CollisionShape2D.rotation = move_toward(
		$Area2D/CollisionShape2D.rotation, target, ROT_SPEED * delta)
		$CardImage.rotation = move_toward($CardImage.rotation, target, ROT_SPEED * delta)
		$Name.rotation = move_toward($Name.rotation, target, ROT_SPEED * delta)

		# 判断已经转到目标角度，停止并重置
		if abs($CardImage.rotation - target) < 0.001:
			rotation_bool = false
			


func use_bool(bool):
	if bool:
		label_rotation_bool = 1
		$Area2D.collision_mask = 1
		usebool = 1
		$CardImage.modulate = Color(1,1,1)
	else:
		label_rotation_bool = 0
		$Area2D.collision_mask = 16
		usebool = 0
		

func group_change():
	add_to_group("card0_"+$Color.text)


func card_rotation():
	rotation_bool = 1
	start_rot = $Area2D/CollisionShape2D.rotation

func visible(bool):
	if bool:
		label_rotation_bool = 0
		$Label.visible = true
		$Name.visible = true
		$".".scale.x = 1
		$".".scale.y = 1
		hower_bool = 1
		$CardImage.texture = load("res://LSQ/sucai/"+ $Color.text + "_"+$Function.text+"_CARD.png")
		$CardImage.modulate = Color(0.7,0.7,0.7)
	else:
		$Label.visible = false
		$Name.visible = false
		$Area2D.collision_mask = 16
		hower_bool = 0
		$".".scale.x = 0.7
		$".".scale.y = 0.7
		$CardImage.modulate = Color(1,1,1)
		
		$CardImage.texture = load("res://LSQ/sucai/111.png")
	
#fa song xin hao
func _on_area_2d_mouse_entered() -> void:
	if hower_bool:
		emit_signal("hovered",self)


func _on_area_2d_mouse_exited() -> void:
	if hower_bool:
		emit_signal("hovered_off",self)

# 新增：连续旋转两次（240度）的触发接口
func card_rotation_double():
	rotation_bool = 1
	start_rot = $Area2D/CollisionShape2D.rotation
	# 修改临时目标，使其跨越两倍的 TARGET_ROT 弧度 [cite: 9, 34]
	# 这样在 _process 帧更新中， move_toward 会一口气直接滑向 240° 的目标点 [cite: 36-39]
	var double_target = start_rot + (TARGET_ROT * 2)
	
	# 覆盖执行，使其直接向双倍目标靠拢
	_override_rotation_target(double_target)

# 辅助重写接口，配合双倍旋转
func _override_rotation_target(custom_target: float):
	var tween = create_tween().set_parallel(true)
	tween.tween_property($Area2D/CollisionShape2D, "rotation", custom_target, 0.85).set_trans(Tween.TRANS_SINE)
	tween.tween_property($CardImage, "rotation", custom_target, 0.85).set_trans(Tween.TRANS_SINE)
	tween.tween_property($Name, "rotation", custom_target, 0.85).set_trans(Tween.TRANS_SINE)
	
	# 动画播完后关闭 rotation_bool 开关 [cite: 42]
	await tween.finished
	rotation_bool = false
