extends Node2D

signal hovered
signal hovered_off

var rotation_bool = 0
var starting_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# all cards must be a child of cardmannagere or error!!!!!!!!!!!!!!!!!!!!!!!!!
	add_to_group("card")
	get_parent().connect_card_signals(self)
	$Code.visible =  false
	$Color.visible =  false
	$Function.visible =  false
	$Name.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rotation_bool:
		if $CardImage.rotation == 240 and $Area2D/CollisionShape2D.rotation == 240:
			if $CardImage.rotation < 360:
				$Area2D/CollisionShape2D.rotation += 5*delta
				$CardImage.rotation += 5*delta
			$Area2D/CollisionShape2D.rotation =0
			$CardImage.rotation =0
			rotation_bool = 0
			return
		elif $CardImage.rotation == 120 and $Area2D/CollisionShape2D.rotation == 120:
			if $CardImage.rotation < 240:
				$Area2D/CollisionShape2D.rotation -= 5*delta
				$CardImage.rotation -= 5*delta
			$Area2D/CollisionShape2D.rotation = 240
			$CardImage.rotation = 240
			rotation_bool = 0
			return
		elif $CardImage.rotation == 0 and $Area2D/CollisionShape2D.rotation == 0:
			if $CardImage.rotation < 120:
				$Area2D/CollisionShape2D.rotation -= 5*delta
				$CardImage.rotation -= 5*delta
			$Area2D/CollisionShape2D.rotation = 120
			$CardImage.rotation = 120
			rotation_bool = 0
			return
	pass



func card_rotation():
	rotation_bool = 1
	
#fa song xin hao
func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered",self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)

	
