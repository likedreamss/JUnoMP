extends Node2D
class_name Unit

signal move_finished

@export var player_id:int = 0
@export var current_tile:Vector2i

@export var move_speed:float = 200.0

var target_position:Vector2
var is_moving := false

func set_tile(tile:Vector2i, game_area):
	current_tile = tile
	position = game_area.get_global_from_tile(tile)

func move_to_tile(tile:Vector2i, game_area):
	current_tile = tile
	target_position = game_area.get_global_from_tile(tile)
	is_moving = true

func _process(delta):
	if is_moving:
		position = position.move_toward(target_position, move_speed * delta)
		if position.distance_to(target_position) < 2:
			position = target_position
			is_moving = false
			move_finished.emit()

func setup(id:int):
	player_id = id

	var sprite = $Sprite2D

	match player_id:
		0: sprite.modulate = Color.RED
		1: sprite.modulate = Color.GREEN
		2: sprite.modulate = Color.BLUE
