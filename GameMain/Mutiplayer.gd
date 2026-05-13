extends Control

const PORT = 123

const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()

@export var player1_filed_scene : PackedScene
@export var player2_filed_scene : PackedScene

func _on_host_button_pressed() -> void:
	disable_buttons()
	
	peer.create_server(PORT)
	
	multiplayer.multiplayer_peer = peer
	
	var player1_scene  = player1_filed_scene.instantiate()
	add_child(player1_scene)
	
	multiplayer.peer_connected.connect(_on_peer_connected)




func _on_join_button_pressed() -> void:
	disable_buttons()
	
	peer.create_client(SERVER_ADDRESS,PORT)
	
	multiplayer.multiplayer_peer = peer
	
	var player1_scene  = player1_filed_scene.instantiate()
	add_child(player1_scene)
	
	var player2_scene  = player2_filed_scene.instantiate()
	add_child(player2_scene)
	
func _on_peer_connected(peer_id):
	var player2_scene  = player2_filed_scene.instantiate()
	add_child(player2_scene)
	
	
func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false
