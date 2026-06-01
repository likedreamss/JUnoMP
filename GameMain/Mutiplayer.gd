extends Node2D

const PORT = 12345  # 改用大端口，避免冲突
const SERVER_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()

@export var player1_filed_scene : PackedScene
@export var player2_filed_scene : PackedScene

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false

# 主机（服务器）
func _on_host_button_pressed() -> void:
	disable_buttons()
	
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

	# 【关键修复】等一帧再生成玩家，让网络完全启动
	await get_tree().process_frame
	
	var player1_scene = player1_filed_scene.instantiate()
	add_child(player1_scene)
	

	
# 客户端
func _on_join_button_pressed() -> void:
	disable_buttons()
	
	peer.create_client(SERVER_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

	# 【关键修复】等一帧
	await get_tree().process_frame
	
	var player1_scene = player1_filed_scene.instantiate()
	add_child(player1_scene)
	
	player1_scene.client_set_up()
	
	
	
func _on_peer_connected(peer_id):
	if multiplayer.is_server():
		print("客户端连接成功！peer_id: ", peer_id)
		var player2_scene = player2_filed_scene.instantiate()
		add_child(player2_scene)
		get_node("Player1").host_set_up()
	

func disable_buttons():
	$HostButton.disabled = true
	$HostButton.visible = false
	$JoinButton.disabled = true
	$JoinButton.visible = false

func able_buttons():
	$HostButton.disabled = 0
	$HostButton.visible = 1
	$JoinButton.disabled = 0
	$JoinButton.visible = 1

func _on_offline_pressed() -> void:
	$online.disabled = true
	$online.visible = false
	$offline.disabled = true
	$offline.visible = false
	var player1_scene = player1_filed_scene.instantiate()
	add_child(player1_scene)

func _on_online_pressed() -> void:
	$online.disabled = true
	$online.visible = false
	$offline.disabled = true
	$offline.visible = false
	able_buttons()
