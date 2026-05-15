extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("PASS")
	await get_tree().create_timer(1).timeout
	$Area2D.collision_mask = 8
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func pass_bool(bool):
	if bool:
		$Area2D.collision_mask = 8
	else:
		$Area2D.collision_mask = 32
