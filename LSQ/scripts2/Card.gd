extends Node2D

signal hovered
signal hovered_off

var rotation_bool = 0
var aaa
var bbb
var starting_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# all cards must be a child of cardmannagere or error!!!!!!!!!!!!!!!!!!!!!!!!!
	add_to_group("card")
	get_parent().connect_card_signals(self)
	$Code.visible =  false
	$Color.visible =  false
	$Function.visible =  false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rotation_bool:
		aaa = $Area2D/CollisionShape2D.rotation
		$Area2D/CollisionShape2D.rotation += 5*delta
		$Label.rotation += 5*delta
		if $CardImage.rotation > 60:
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
