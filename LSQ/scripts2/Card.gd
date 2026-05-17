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
